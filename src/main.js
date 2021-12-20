const { APIController } = require("api-tools-ts");
const api = new APIController("/");
const path = __dirname + "/category";
const { findFiles } = require("./module/getFilesRecursivly");

const questionFilesFilter = findFiles(path, "json");
let questionFilesWithPath = [];

for (const file of questionFilesFilter) {
  const files = require(`${path}/${file}`);
  questionFilesWithPath.push(files);
}

api.AddEndPoint("/", "get", (req, res) => {
  res.send(
    "Try /training, /training/:trainingID or /training/:trainingID/question/:question"
  );
});

api.AddEndPoint("/training", "get", (req, res) => {
  const trainingGuidList = questionFilesWithPath.map((training) => {
    return {
      training: training.training,
      trainingID: training.trainingID,
      NumberOfQuestions: training.questions.length,
    };
  });
  res.status(200).json(trainingGuidList);
});

api.AddEndPoint("/training/:trainingID", "get", (req, res) => {
  const getInfoById = questionFilesWithPath
    .filter((file) => file.trainingID.includes(req.params.trainingID))
    .map((question) => question.questions);

  const [listOfQuestions] = getInfoById;
  res.status(200).json(listOfQuestions);
});

api.AddEndPoint(
  "/training/:trainingID/question/:questionID",
  "get",
  (req, res) => {
    const traininglang = questionFilesWithPath.filter((file) =>
      file.trainingID.includes(req.params.trainingID)
    );
    try {
      res.status(200).json(traininglang[0].questions[req.params.questionID]);
    } catch (err) {
      res.status(500).send("Something broke!");
    }
  }
);

api.port = 3000;
api.startServer({ useDefaultMiddlewares: "true" });
