const fs=require('fs').promises;

const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');

const serviceAccount=require('../Private/joelgrayson-techmap.json');

initializeApp({
    credential: cert(serviceAccount)
});

const db=getFirestore(); //use the (default) firebase database because this is what @FirestoreQuery works with


async function uploadJSON(filename, region) {
    /** @type {{ name: string; address: string; id: string; lat: number; lng: number; imageName: string; description: string, wikipediaSlug: string, isHeadquarters: boolean }[]} */
    const companies=JSON.parse(await fs.readFile(filename));

    const collectionRef=db.collection('companies');
    for (const company of companies) {
        process.stdout.write('*');
        // console.log(company);
        
        await collectionRef.doc(company.id).set({
            name: company.name,
            address: company.address,
            lat: company.lat,
            lng: company.lng,
            imageName: company.imageName,
            description: company.description,
            wikipediaSlug: company.wikipediaSlug,
            isHeadquarters: company.isHeadquarters,
            region
        });
    }
}


async function main() {
    // Some of these files were edited so please if you (me) rebuild them, do it with caution.

    console.log('Uploading Bay Area 1');
    await uploadJSON('./2-geocoded/bay-area/1/final-output.json', 'bay-area');
    console.log('\nUploading Bay Area 2');
    await uploadJSON('./2-geocoded/bay-area/2/final-output.json', 'bay-area');
    console.log('\nUploading Bay Area 3');
    await uploadJSON('./2-geocoded/bay-area/3/final-output.json', 'bay-area');

    console.log('\nUploading NYC 1');
    await uploadJSON('./2-geocoded/nyc/1/final-output.json', 'nyc');
    console.log('\nUploading NYC 2');
    await uploadJSON('./2-geocoded/nyc/2/final-output.json', 'nyc');

    console.log('\nUploading Seattle');
    await uploadJSON('./2-geocoded/seattle/1/final-output.json', 'seattle');


    // Create one large file called all-companies.json. It is useful since I can paste it into LLMs to tell me if there are any duplicates or errors.
    const forAllCombined=[
        './2-geocoded/bay-area/1/final-output.json',
        './2-geocoded/bay-area/2/final-output.json',
        './2-geocoded/bay-area/3/final-output.json',
        './2-geocoded/nyc/1/final-output.json',
        './2-geocoded/nyc/2/final-output.json',
        './2-geocoded/seattle/1/final-output.json'
    ];
    let allCompanies=[];
    for (const fileName of forAllCombined) {
        const companies=JSON.parse(await fs.readFile(fileName));
        allCompanies=allCompanies.concat(companies);
    }
    fs.writeFile('all-companies.json', JSON.stringify(allCompanies, null, 4));
}


main();

