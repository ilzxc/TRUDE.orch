genHarm[] armonie = new genHarm[100];
float mutationRate = 0.01;

int generation = 0;
int runCounter = 0;
int numSolutions = 10;

// chord00:
float[] sourceFreq = { 1864.655029, 622.253967, 391.995422, 1244.507935, 466.163757, 783.990845, 415.304688, 49., 3951.066406, 3135.963379, 3322.4375, 2793.825928, 2489.015869, 1975.533203, 1046.502319, 783.990845 };
float[] sourceAmp =  { 0.3,         0.3,        0.3,        0.5,         1.,         0.5,        0.2,        0.7, 0.4,         0.4,         0.4,       0.2,         0.2,         0.6,         0.6,         0.3        };
float   targetRoughness;
int     maxPool;
boolean done = false;
String  fnBase = "chord00whole";
String  fileName = fnBase + "_" + runCounter;

float lowFreq = mtof(60 - (12 * 5)); 
float highFreq = mtof(60 + (12 * 3));



//---------------------------------------------------------------------------
// SETUP: -----------------------------------------------------------------//
//---------------------------------------------------------------------------
void setup() {
  
  // define sources:
  /*
  sourceFreq = new float[(int)(random(6, 20))];
  sourceAmp  = new float[sourceFreq.length];
  for (int i = 0; i < sourceFreq.length; i++) {
    sourceFreq[i] = random(50, 4000);
    sourceAmp[i]  = random(1);
  }
  
  float multiplier = 1.0 / max(sourceAmp);  
  for (int i = 0; i < sourceAmp.length; i++) {
    sourceAmp[i] = sourceAmp[i] * multiplier;
  }
  */
  /* 
  {
    PrintWriter output;
    output = createWriter(fileName + "_src.txt");
    for (int i = 0; i < sourceFreq.length; i++) {
      output.println(i + ", " + sourceFreq[i] + " " + sourceAmp[i] + ";");
    }
    output.flush();
    output.close();
  }
  */
  
  if (sourceFreq.length != sourceAmp.length) {
    println("Error: frequency & amplitude arrays mismatch.");
    exit();
  }
  
  int partials = sourceFreq.length;
  maxPool = 5000;
  
  // instantiate armonies:
  for (int i = 0; i < armonie.length; i++) {
    armonie[i] = new genHarm(partials, lowFreq, highFreq, true);
  }
  
  targetRoughness = armonie[0].Df(sourceFreq, sourceAmp);
  println("TARGET ROUGHNESS IS: " + targetRoughness);
}

//---------------------------------------------------------------------------
// MAIN LOOP: -------------------------------------------------------------//
//---------------------------------------------------------------------------
void draw() {
  float Sum = 0;
  for (int i = 0; i < armonie.length; i++ ) {
    armonie[i].normalizeAmps();          // max amplitude = 1.0
    Sum += armonie[i].roughness();
    armonie[i].fitness(targetRoughness);
  }
  
  println("Current Population Average Roughness: " + Sum / armonie.length + " / " + targetRoughness);
  
  ArrayList<genHarm> matingPool = new ArrayList<genHarm>();
  
  int[] scaledFitnesses = scaledFitnesses();
  if (done) { 
    runCounter++;
    if (runCounter == numSolutions) {
      exit();
    } else {
      fileName = (fnBase + "_" + runCounter);
      setup();
      done = false;
    }
  }
  
  for (int i = 0; i < armonie.length; i++) {
    for (int j = 0; j < scaledFitnesses[i]; j++) {
      matingPool.add(armonie[i]);
    }
  }
  
  for (int i = 0; i < armonie.length; i++) {
    if(matingPool.size() != 0) {
        int a = int(random(matingPool.size()));
        int b = int(random(matingPool.size()));
        genHarm partnerA = matingPool.get(a);
        genHarm partnerB = matingPool.get(b);
        genHarm child = partnerA.crossover(partnerB);
        child.mutate(mutationRate);
        armonie[i] = child;
    } else { println("matingPool not populated."); exit(); }
  }
  
  generation++;
}


//---------------------------------------------------------------------------
// FITNESS -> # OF INSTANCES IN THE MATING POOL: --------------------------//
//---------------------------------------------------------------------------
int[] scaledFitnesses() {
  
  float[] fitnesses = new float[armonie.length];
  int[]   result    = new int[fitnesses.length];
  
  for (int i = 0; i < armonie.length; i++) {
    fitnesses[i] = armonie[i].fitness;
    if (fitnesses[i] < 0.00001) {
      armonie[i].DUMPOUTPUT(fileName + "sol");
      done = true;
    }
  }
  
  float minfit = max(fitnesses);
  float maxfit = min(fitnesses);
 
  for (int i = 0; i < armonie.length; i++) {
    if (minfit != maxfit) {
      result[i] = (int)(map(fitnesses[i], minfit, maxfit, 5, 30));
    } else { result[i] = int(random(30)); }
  }
  
  
  
  return result;
}

//---------------------------------------------------------------------------
// MTOF / midi to freq ----------------------------------------------------//
//---------------------------------------------------------------------------
private float mtof(float midi) {  
  return (pow( 2, ((midi - 69) / 12) ) * 440.0);
}




