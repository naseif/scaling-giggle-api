const express = require('express')
let app = express()
const port = 51337;
const cors = require("cors")
const fs = require("fs");
const path = __dirname
console.log("hey hey")
const questionFilesFilter = fs.readdirSync(path).filter((file) => file.endsWith(".json"));
let questionFilesWithPath = [] 
for (const file of questionFilesFilter) {
    const files = require(`${path}/${file}`)
    questionFilesWithPath.push(files)
} 


app.use(cors())

app.get(`/training/:trainingID/question/:questionID`, function (req, res) {

    const traininglang = questionFilesWithPath.filter((file) => file.trainingID.includes(req.params.trainingID))
    
    try {
        res.json(traininglang[0].questions[req.params.questionID]);
    } catch (err) {
        res.status(500).send('Something broke!');
    } 

})

app.listen(port, () => {
    console.log(`Example app listening at http://localhost:${port}`)
})
