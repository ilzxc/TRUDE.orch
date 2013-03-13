genHarm[] armonie = new genHarm[100];
float mutationRate = 0.01;

float[] sourceFreq;
float[] sourceAmp;
float   targetRoughness;
int     maxPool;
boolean done = false;
String  fileName = "RANDOM06";

int generation = 0;


//---------------------------------------------------------------------------
// SETUP: -----------------------------------------------------------------//
//---------------------------------------------------------------------------
void setup() {
  
  // define sources:
  sourceFreq = new float[11];
  sourceAmp  = new float[sourceFreq.length];
  for (int i = 0; i < sourceFreq.length; i++) {
    sourceFreq[i] = random(50, 4000);
    sourceAmp[i]  = random(1);
  }
  
  float multiplier = 1.0 / max(sourceAmp);  
  for (int i = 0; i < sourceAmp.length; i++) {
    sourceAmp[i] = sourceAmp[i] * multiplier;
  }
  
  PrintWriter output;
    
  output = createWriter(fileName + "_src.txt");
  for (int i = 0; i < sourceFreq.length; i++) {
    output.println(i + ", " + sourceFreq[i] + " " + sourceAmp[i] + ";");
  }
  output.flush();
  output.close();
  
  if (sourceFreq.length != sourceAmp.length) {
    println("Error: frequency & amplitude arrays mismatch.");
    exit();
  }
  
  int partials = sourceFreq.length;
  boolean useMidi = false;
  maxPool = 5000;
  
  // instantiate armonies:
  for (int i = 0; i < armonie.length; i++) {
    armonie[i] = new genHarm(partials, useMidi, true);
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
  if (done) { exit(); }
  
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
