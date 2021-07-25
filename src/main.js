const express = require("express");
let app = express();
let https = require("https");
let http = require("http");

const port = 8080;
const cors = require("cors");
const fs = require("fs");
const path = __dirname;

const questionFilesFilter = fs
  .readdirSync(path)
  .filter((file) => file.endsWith(".json"));
let questionFilesWithPath = [];
for (const file of questionFilesFilter) {
  const files = require(`${path}/${file}`);
  questionFilesWithPath.push(files);
}

app.use(cors());

app.get(`/training`, function (req, res) {
  const trainingGuidList = questionFilesWithPath.map((training) => {
    return {
      training: training.training,
      trainingID: training.trainingID,
      NumberOfQuestions: training.questions.length,
    };
  });
  try {
    res.json(trainingGuidList);
  } catch (err) {
    res.status(500).send("Something broke!");
  }
});

app.get(`/training/:trainingID`, function (req, res) {
  const getInfoById = questionFilesWithPath
    .filter((file) => file.trainingID.includes(req.params.trainingID))
    .map((question) => question.questions);

  const [listOfQuestions] = getInfoById;
  try {
    res.json(listOfQuestions);
  } catch (err) {
    res.status(500).send("Something broke!");
  }
});

app.get(`/training/:trainingID/question/:questionID`, function (req, res) {
  const traininglang = questionFilesWithPath.filter((file) =>
    file.trainingID.includes(req.params.trainingID)
  );

  try {
    res.json(traininglang[0].questions[req.params.questionID]);
  } catch (err) {
    res.status(500).send("Something broke!");
  }
});

if (fs.existsSync('../hosting/key.pem')) {
  const options = {
    key: fs.readFileSync('../hosting/key.pem'),
    cert: fs.readFileSync('../hosting/cert.pem')
  };

  https.createServer(app).listen(443,() => {
    console.log(`App listening at https://localhost`);
  })
} else {
  http.createServer(app).listen(port,() => {
    console.log(`App listening at http://localhost:${port}`);
  })
}


