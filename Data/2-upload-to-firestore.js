const fs=require('fs').promises;

const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');

const serviceAccount=require('../Private/joelgrayson-techmap.json');

initializeApp({
    credential: cert(serviceAccount)
});

const db=getFirestore(); //use the (default) firebase database because this is what @FirestoreQuery works with
// const db=getFirestore('techmap');

// Upload the data
(async ()=>{
    /** @type {{ name: string; address: string; id: string; lat: number; lng: number; imageName: string; description: string }[]} */
    const companies=JSON.parse(await fs.readFile('./2-geocoded/bay-area/2/output.json'));
    const collectionRef=db.collection('companies');
    for (const company of companies) {
        process.stdout.write('*')
        await collectionRef.doc(company.id).set({
            name: company.name,
            address: company.address,
            lat: company.lat,
            lng: company.lng,
            imageName: company.imageName,
            description: company.description
        });
    }
})();

