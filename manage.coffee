nano = require('nano')('http://127.0.0.1:5984')

dbname = "blocks"
db = nano.use(dbname)
nano.db.create(dbname)

