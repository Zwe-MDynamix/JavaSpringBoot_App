package com.example.livescore.controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.Map;
@RestController
public class ScoreController {
  @GetMapping("/score")
  public Map<String,Object> score() {
    return Map.of("game","Sky Heroes", "score","3-2", "status","live");
  }
}
