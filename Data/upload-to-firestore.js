const admin=require('firebase-admin');
const fs=require('fs').promises;

const serviceAccount=require('../Private/joelgrayson-techmap-firebase-admin.json');

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId: serviceAccount.project_id
});

const db=admin.firestore();

// Upload the data
(async ()=>{
    try {
        console.log('🔍 Checking Firestore connection...');
        
        // First, try to create a simple document to initialize Firestore
        const testRef = db.collection('_test').doc('connection');
        await testRef.set({ timestamp: new Date(), test: true });
        console.log('✅ Firestore connection successful!');
        
        // Clean up test document
        await testRef.delete();
        console.log('🧹 Cleaned up test document');
        
        // Now list collections
        const collections = await db.listCollections();
        console.log('📁 Existing collections:', collections.map(c => c.id));
        
        console.log('📦 Loading company data...');
        /** @type {{ name: string; address: string; id: string; lat: number; lng: number; imageName: string; description: string }[]} */
        const companies=JSON.parse(await fs.readFile('./output-with-desc.json'));
        console.log(`Found ${companies.length} companies to upload`);
        
        const collectionRef=db.collection('companies');
        for (let i = 0; i < companies.length; i++) {
            const company = companies[i];
            console.log(`⬆️  Uploading ${i + 1}/${companies.length}: ${company.name}`);
            await collectionRef.doc(company.id).set({
                name: company.name,
                address: company.address,
                lat: company.lat,
                lng: company.lng,
                imageName: company.imageName,
                description: company.description
            });
        }
        
        console.log('🎉 All companies uploaded successfully!');
        
    } catch (error) {
        console.error('❌ Error:', error.message);
        console.error('Error code:', error.code);
        
        if (error.code === 5) {
            console.error('\n🚨 Firestore Database Not Found!');
            console.error('📋 To fix this:');
            console.error('1. Go to: https://console.firebase.google.com');
            console.error('2. Select your project');
            console.error('3. Click "Firestore Database" in the left menu');
            console.error('4. Click "Create database"');
            console.error('5. Choose "Start in test mode"');
            console.error('6. Select a location (e.g., us-central1)');
            console.error('7. Wait for database creation to complete');
        }
        
        process.exit(1);
    }
})();

