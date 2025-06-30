const fs=require('fs').promises;

const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');

const serviceAccount=require('../Private/joelgrayson-techmap.json');

initializeApp({
    credential: cert(serviceAccount)
});

const db=getFirestore(); //use the (default) firebase database because this is what @FirestoreQuery works with


async function uploadJSON(filename) {
    /** @type {{ name: string; address: string; id: string; lat: number; lng: number; imageName: string; description: string, wikipediaSlug: string }[]} */
    const companies=JSON.parse(await fs.readFile(filename));

    const collectionRef=db.collection('companies');
    for (const company of companies) {
        process.stdout.write('*')
        await collectionRef.doc(company.id).set({
            name: company.name,
            address: company.address,
            lat: company.lat,
            lng: company.lng,
            imageName: company.imageName,
            description: company.description,
            wikipediaSlug: company.wikipediaSlug
        });
    }
}


async function main() {
    console.log('Uploading Bay Area 1');
    await uploadJSON('./2-geocoded/bay-area/1/output-with-wiki.json');
    console.log('\nUploading Bay Area 2');
    await uploadJSON('./2-geocoded/bay-area/2/output-with-wiki.json');
    console.log('\nUploading NYC');
    await uploadJSON('./2-geocoded/nyc/output-with-wiki.json');
}


main();

