package com.example.livescore;
import com.example.livescore.controller.ScoreController;
import org.junit.jupiter.api.Test;
import static org.assertj.core.api.Assertions.assertThat;
public class ScoreControllerTest {
  @Test void testScoreResponse() {
    ScoreController c = new ScoreController();
    var map = c.score();
    assertThat(map).containsKeys("game","score","status");
  }
}
