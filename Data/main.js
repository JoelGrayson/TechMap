require('dotenv').config();
const fs=require('fs');
const fsPromises=fs.promises;
const NodeGeocoder=require('node-geocoder');
const axios=require('axios');

const geocoder=NodeGeocoder({
    provider: 'google',
    apiKey: process.env.GCLOUD_API_KEY
});


(async ()=>{
    const data=JSON.parse(await fsPromises.readFile('./input-data.json'));
    for (let i=0; i<data.length; i++) {
        process.stdout.write('*');
        const res=await geocoder.geocode(data[i].address);
        const lat=res?.[0]?.latitude, lng=res?.[0]?.longitude;
        if (lat && lng) {
            data[i].lat=lat;
            data[i].lng=lng;
        }
        const logoUrl=data[i].logo+'?token='+process.env.LOGO_SECRET_TOKEN;
        const imageName=data[i].logo.split('/').at(-1);
        data[i].imageName=imageName;
        // axios.get(logoUrl, {
        //     responseType: 'stream'
        // })
        //     .then(res=>{
        //         res.data.pipe(fs.createWriteStream('images/'+imageName));
        //     });
    }
    const outputString=JSON.stringify(data, null, 4);
    await fsPromises.writeFile('output.json', outputString);
    // console.log(outputString);
    console.log('Done writing', data.length, 'companies to output.json. Downloading logo images to images folder.');
})();


// logo=logo.replace('YOUR-LOGODEV-TOKEN', process.env.LOGO_DEV_TOKEN);

// const res=await geocoder.geocode(address);

// if (res?.[0]?.latitude) {
// output.push({
//     name,
//     address,
//     lat: res.latitude,
//     lng: res.longitude,
//     logo
// });
// } else {
// console.log('There is no geocoding for the address', address, 'from item', result.data);
// }

//         console.log('Done. Wrote', output.length, 'companies to output.json');
//         fs.writeFile('./output.json', JSON.stringify(output));

