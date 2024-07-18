const express = require('express');
const path = require('path');
const { runPowershellScript } = require('./scriptrunner');
const { readJSON } = require('./readJSON');

const app = express();
const PORT = 3366;

app.get('/', (req, res) => {
    try{
        res.sendFile(path.join(__dirname, 'index.html'));
    }catch(err){
        console.error(err);
    }
});
app.get('/device-info', (req,res)=>{
    try {
        const data = readJSON('data.json');
        res.status(200).send(data);
    } catch (err) {
        console.error(err); 
        res.status(500).send('Error retrieving device info');
    }
})
app.get('/reload',async(req,res)=>{
    try{
        console.log("Please Collecting Device Information");
        await runPowershellScript();
        const data = readJSON('data.json');
        res.status(200).send(data);
    }catch(err){
        console.error(err)
    }
})
// Start the server
app.listen(PORT, async() => {
    console.log("Please Collecting Device Information");
    await runPowershellScript();
    console.log(`Server is running on http://localhost:${PORT}`);
});




