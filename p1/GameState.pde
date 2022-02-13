final class GameState {
  // CONSTANTS
  private int SCORE_INC = 25;
  private int CITIES_INC = 100;

  private int wave;
  private int score;
  private int difficulty;
  
  // keep in gamestate so we can in future adjust throughout game
  private float gravityForce;
  private float dragForce;  
  
  public GameState(int wave, float gravityForce, float dragForce) {
    this.wave = wave;
    this.score = 0;
    this.gravityForce = gravityForce;
    this.dragForce = dragForce;
  }

  int getWaveMultiplier() {
    int waveVal = wave + 1;
    switch (waveVal) {
      case 1: return 1;
      case 2: return 1;
      case 3: return 2;
      case 4: return 2;
      case 5: return 3;
      case 6: return 3;
      case 7: return 4;
      case 8: return 4;
      case 9: return 5;
      case 10: return 5;
      default: return 6;
    }
  }
  
  // getters
  public int getWave() { return wave; }
  public int getDifficulty() { return difficulty; }
  public float getGravity() { return gravityForce; }
  public float getDrag() { return dragForce; }
  public int getScore() { return score; }

  // incrementers
  public void incWave() { wave++; }
  public void updateScore(int numbBlownUp) {
    int scoreInc = numbBlownUp * SCORE_INC * getWaveMultiplier();

    score += scoreInc;
  }

  public void updateScoreCities(int surviving) {
    int scoreInc = surviving * CITIES_INC * getWaveMultiplier();

    score += scoreInc;
  }

  public void checkIfCanAddNewCity(City[] cities) {
    ArrayList<Integer> destroyed = new ArrayList<>();

    if (score > 10000) {
      // can add new city
      for (int i = 0; i < cities.length; i++) {
        if (cities[i].destroyed) {
          destroyed.add(i);
        }
      }

      // get random index
      int r = (int) random(destroyed.size());
      City cityToReestablish = cities[destroyed.get(r)];
      cityToReestablish.destroyed = false;
    }
  }
}
