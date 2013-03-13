class genHarm {
  
  private   float[]   freqs; // spectral aggregate :: frequencies
  private   float[]   amps;  // spectral aggregate :: amplitudes
  protected float     fitness;
  private   boolean   midiMode;
  
  //---------------------------------------------------------------------------
  // CONSTRUCTOR: -----------------------------------------------------------//
  //---------------------------------------------------------------------------
  genHarm(int numPartials, boolean midi, boolean instantiate) {
    // initialization:
    freqs = new float[numPartials];
    amps  = new float[numPartials];
    midiMode = midi;
    
    if (instantiate) {
      for (int i = 0; i < numPartials; i++) {
        freqs[i] = (midi) ? mtof(random(24, 96)) : random(50, 4000);
        amps[i]  = random(1);
      }
    }
  }
  
  //---------------------------------------------------------------------------
  // NORMALIZE AMPS: --------------------------------------------------------//
  //---------------------------------------------------------------------------
  public void normalizeAmps() {
    float multiplier = 1.0 / max(amps);
    
    for (int i = 0; i < amps.length; i++) {
      amps[i] = amps[i] * multiplier;
    }
  }
  
  
  //---------------------------------------------------------------------------
  // FITNESS: ---------------------------------------------------------------//
  //---------------------------------------------------------------------------
  public void fitness(float target) {
    float roughness = Df(freqs, amps);
    fitness = abs(roughness - target); // perfect fit is zero
  }
  
  public float roughness() {
    return Df(freqs, amps);
  }
  
  //---------------------------------------------------------------------------
  // CROSSOVER: -------------------------------------------------------------//
  //---------------------------------------------------------------------------
  public genHarm crossover(genHarm partner) {
    genHarm child = new genHarm(freqs.length, midiMode, false);
    int midpoint = int(random(freqs.length));
    for (int i = 0; i < freqs.length; i++) {
      if (i > midpoint) {
        child.freqs[i] = freqs[i];
        child.amps[i]  = amps[i];
      } else {
        child.freqs[i] = partner.freqs[i];
        child.amps[i]  = partner.amps[i];
      }
    }
      return child;
  }
  
  //---------------------------------------------------------------------------
  // MUTATION: --------------------------------------------------------------//
  //---------------------------------------------------------------------------
  public void mutate(float mutationRate) {
    for (int i = 0; i < freqs.length; i++) {
      if (random(1) < mutationRate) {
        freqs[i] = (midiMode) ? mtof(random(24, 96)) : random(50, 4000);
        if (random(1) < 0.5) {
          amps[i] = random(1);
        }
      }
    }
  }
  
  //---------------------------------------------------------------------------
  // DUMP OUTPUT: -----------------------------------------------------------//
  //---------------------------------------------------------------------------
  public void DUMPOUTPUT(String filename) {
    PrintWriter output;
    
    output = createWriter(filename + ".txt");
    for (int i = 0; i < freqs.length; i++) {
      output.println(i + ", " + freqs[i] + " " + amps[i] + ";");
    }
    output.flush();
    output.close();
    
    output = createWriter(filename + "_midi.txt");
    for (int i = 0; i < freqs.length; i++) {
      output.println(i+ ", " + ftom(freqs[i]) + " " + amps[i] + ";");
    }
    output.flush();
    output.close();
  }
  
  //---------------------------------------------------------------------------
  // PRIVATE METHODS: -------------------------------------------------------//
  //---------------------------------------------------------------------------
  // MTOF / midi to freq ----------------------------------------------------//
  //---------------------------------------------------------------------------
  private float mtof(float midi) {  
    return (pow( 2, ((midi - 69) / 12) ) * 440.0);
  }
  
  //---------------------------------------------------------------------------
  // FTOM / freq to midi ----------------------------------------------------//
  //---------------------------------------------------------------------------
  private float ftom(float frequency) {
    return 69 + 12 * ( log(frequency / 440.0) / log(2.0) );
  }
  
  //---------------------------------------------------------------------------
  // ROUGHNESS COMPUTATION: -------------------------------------------------//
  //---------------------------------------------------------------------------
  // Roughness of a complex timbre F: { freqs[], amps[] } -------------------//
  //---------------------------------------------------------------------------
  private float Df(float[] freq, float[] amp)
  {
    // for debug only:
    if (freq.length != amp.length) {
      println("ERROR: array size mismatch.");
      exit();
    }
    
    float Sum = 0;
    
    for (int i = 0; i < freq.length; i++) {
      for (int j = 0; j < freq.length; j++) {
        Sum += d(freq[i], freq[j], amp[i], amp[j]);
      }
    }
    
    return (Sum); // unscaled output of the cascading sum
  }
  
  //---------------------------------------------------------------------------
  // Roughness of freqs f1, f2 @ amps amp1, amp2: ---------------------------//
  //---------------------------------------------------------------------------
  private float d(float f1, float f2, float amp1, float amp2)
  {  
    // independent variables:
    float dStar = 0.24;      // maximal dissonance, from Sethares
    float a1 = -3.5;         // Sethares' coefficients for P&L crit bandwidth;
    float a2 = -5.75;
    float s1 = 0.0207;       // least-squares approx. of scaling function, from
    float s2 = 18.96;        //    Sethares...
    
    // computational variables from Sethares:
    float fmin = min(f1, f2);
    float x = abs(f2 - f1);
    float s = dStar / (s1 * fmin + s2);
    
    return (min(amp1, amp2) * (exp(a1 * s * x) - exp(a2 * s * x)));
  }
  
}
