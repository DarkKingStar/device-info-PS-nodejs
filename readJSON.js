const fs = require('fs');
const path = require('path');

exports.readJSON=(filePath)=> {
    const jsonPath = path.resolve(__dirname, filePath); 
    const jsonData = fs.readFileSync(jsonPath, 'utf8'); 
    return JSON.parse(jsonData); 
}
