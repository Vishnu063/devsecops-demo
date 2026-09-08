package com.example.devsecopsdemo.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class DemoController {

    @GetMapping("/api/hello")
    public String hello() {
String broken = null;
    return broken.toUpperCase();
    }

    @GetMapping("/api/secure")
    public String secure() {
        return "Hello, authenticated user!";
    }
}
