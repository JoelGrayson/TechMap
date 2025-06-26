require('dotenv').config();
const fs=require('fs');
const fsPromises=fs.promises;
const NodeGeocoder=require('node-geocoder');
const axios=require('axios');
const uuid=require('uuid').v4;

const geocoder=NodeGeocoder({
    provider: 'google',
    apiKey: process.env.GCLOUD_API_KEY
});


(async ()=>{
    const data=JSON.parse(await fsPromises.readFile('./input-data.json'));
    for (let i=0; i<data.length; i++) {
        process.stdout.write('*');
        data[i].id=uuid();
        const res=await geocoder.geocode(data[i].address);
        const lat=res?.[0]?.latitude, lng=res?.[0]?.longitude;
        if (lat && lng) {
            data[i].lat=lat;
            data[i].lng=lng;
        }
        const imageName=data[i].logo.split('/').at(-1)+'.jpg';
        data[i].imageName=imageName;
        const logoUrl=data[i].logo+'?token='+process.env.LOGO_PUBLIC_TOKEN;
        axios.get(logoUrl, {
            responseType: 'stream'
        })
            .then(res=>{
                res.data.pipe(fs.createWriteStream('images/'+imageName));
            });
        data[i].logo=undefined;
    }
    const outputString=JSON.stringify(data, null, 4);
    await fsPromises.writeFile('output.json', outputString);
    // console.log(outputString);
    console.log('\nDone writing', data.length, 'companies to output.json. Downloading logo images to images folder.');
})();

