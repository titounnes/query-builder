namespace Tito\Driver;


class MyPdo
{

  public function execute(config, sql )
  {
    var con, res, dsn, e;
    if(config["dsn"]=="mysql" || is_null(config["dsn"]))
    {
      let dsn = sprintf("mysql:host=%s;port=%d;dbname=%s", config["host"], 3306, config["dbname"]);
    }
    try{
      let con = new \PDO(dsn, config["uname"], config["psw"]);
      con->setAttribute(\PDO::ATTR_ERRMODE, \PDO::ERRMODE_EXCEPTION);
      let res = con->prepare(sql["query_string"]);
      res->execute(sql["param"]);
      return res;
    }
    catch \PDOException, e {
      throw new \Exception(e->getMessage(). "\nSQL:\n" . sql["sql"]);
    }
  }
}
