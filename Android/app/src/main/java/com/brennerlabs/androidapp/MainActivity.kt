package com.brennerlabs.androidapp

import android.content.Intent
import android.net.Uri
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.widget.Button
import com.google.android.material.appbar.MaterialToolbar

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val toolbar: MaterialToolbar = findViewById(R.id.toolbar)
        setSupportActionBar(toolbar)

        // Set the title explicitly
        supportActionBar?.title = "Welcome"

        val thankYouButton: Button = findViewById(R.id.thankYouButton)

        thankYouButton.setOnClickListener {
            // Navigate to LinkedIn profile
            val linkedInUrl = "https://www.linkedin.com/in/brenneran"
            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(linkedInUrl))
            startActivity(intent)
        }
    }
}
