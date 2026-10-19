package com.shyamal.nutriloop;

import android.os.Bundle;
import com.getcapacitor.BridgeActivity;

public class MainActivity extends BridgeActivity {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        registerPlugin(GoogleDrive.class); // Google sign-in + backup to the user's own Drive app folder
        super.onCreate(savedInstanceState);
    }
}
