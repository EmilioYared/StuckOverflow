require('dotenv').config();
const mongoose = require('mongoose');

mongoose.connect(process.env.MONGO_URI)
  .then(() => {
    console.log('MongoDB connected');
    migrateVotes();
  })
  .catch(err => {
    console.error('MongoDB connection error:', err);
    process.exit(1);
  });

async function migrateVotes() {
  try {
    const db = mongoose.connection.db;
    const answersCollection = db.collection('answers');
    
    const allAnswers = await answersCollection.find({}).toArray();
    
    console.log(`Found ${allAnswers.length} total answers`);
    
    let migratedCount = 0;
    
    for (const answer of allAnswers) {
      console.log(`\nAnswer ${answer._id}:`);
      console.log(`  votes type: ${typeof answer.votes}`);
      console.log(`  votes isArray: ${Array.isArray(answer.votes)}`);
      console.log(`  votes value:`, JSON.stringify(answer.votes));
      
      // Check if votes is not an array (old structure)
      if (!Array.isArray(answer.votes)) {
        console.log(`  -> MIGRATING to empty array`);
        
        // Update to empty array
        await answersCollection.updateOne(
          { _id: answer._id },
          { $set: { votes: [] } }
        );
        
        migratedCount++;
      }
    }
    
    console.log(`\n\nMigration complete! Migrated ${migratedCount} answers.`);
    process.exit(0);
  } catch (error) {
    console.error('Migration error:', error);
    process.exit(1);
  }
}
