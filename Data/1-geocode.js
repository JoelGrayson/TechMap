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
    const data=JSON.parse(await fsPromises.readFile('./1-raw-company-list/nyc/nyc.json'));
    for (let i=0; i<data.length; i++) {
        process.stdout.write('*');
        // console.log(data);
        data[i].id=uuid();
        const res=await geocoder.geocode(data[i].address);
        const lat=res?.[0]?.latitude, lng=res?.[0]?.longitude;
        if (lat && lng) {
            data[i].lat=lat;
            data[i].lng=lng;
        }
        const imageName=data[i].imageName;
        const imageNameWODotCom=imageName.slice(0, -4); //no .com
        const logoUrl='https://img.logo.dev/'+imageNameWODotCom+'?token='+process.env.LOGO_PUBLIC_TOKEN;
        axios.get(logoUrl, {
            responseType: 'stream'
        })
            .then(res=>{
                res.data.pipe(fs.createWriteStream('images/'+imageName));
            });
    }
    const outputString=JSON.stringify(data, null, 4);
    await fsPromises.writeFile('output.json', outputString);
    console.log('\nDone writing', data.length, 'companies to output.json. Downloading logo images to images folder.');
})();

