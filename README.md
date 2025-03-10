# ReelsTek

A Project for RISTEK MobDev Open Recruitment.

## Short Learned Essay

In creating the movie_app, I chose to reference "LetterBox." What I mean by this is adding "social" functionalities where users can see others. To implement this, I needed a database, so I asked ChatGPT for the easiest option, and it suggested Firebase. Then, I began working. First, I used an API key from TMDB to fetch movie data. Initially, I added the key to .env for security, but since others might use my app, I ended up hardcoding it (not ideal).

For development, I used the Firebase emulator, thinking it would keep my database clean. However, this backfired, and as of two hours ago, I was struggling to transition to an online Firebase database. Thankfully, with the help of LLMs and GSGS, I resolved the issue and pushed the final product.

Several packages were essential to this project. For database implementation, I used firebase_core, firebase_auth, firebase_storage, and cloud_firestore, which provide built-in authentication and storage. I also added sqflite and shared_preferences (though I’m unsure if the latter was fully implemented). For API calls, I used http, and for profile pictures, image_picker. I also used several other packages of which I cant mention it all.

One unexpectedly hard thing to implement was statemanagement. I used provider, but getting scene transitions right took an entire day. This experience showed me that state management is a critical aspect of mobile development.

From this project, I learned that proper planning and understanding of data flow are crucial. I come upon alot of unexpected challenges. However, through trial and error, debugging, and leveraging online resources, I managed to overcome them. This experience of development process have taught me adaptability, problem-solving, and the importance of continuously learning from mistakes.
