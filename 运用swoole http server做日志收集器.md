## 运用swoole http server实现集中收取网络日志

* 序   开发网站时一般情况下都会用到分布工部署,此方案主要用于解决并发的压力! 但这样一来日志的收集就遇到了问题,一般的日志都是写文件日志的,用分布式部署后每台机器的都会产生日志,如果分布式用的机器少倒没什么问题,但如果上百台机器呢,这样就会造成日志分布大很多机器上!为解决这些问题,我有一种方案就用日志统一写到一台服务器中上! 那就要用到swoole 的 http server服务! 

* 客户端口代码如下:

  ```php
    public static function send($message, $msgMode) {
          $data['msg'] = $message;
          $url = "http://127.0.0.1:9502";

          if(is_array($message)){
              $data['msg'] = implode(' ', $message);
          }

          $ch = curl_init();
          curl_setopt($ch, CURLOPT_URL, $url);
          curl_setopt($ch, CURLOPT_POST, true);
          curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data)); //如果不用json速度比较慢
          curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
          curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 1);
          curl_setopt($ch, CURLOPT_TIMEOUT, 6);
          $headers = [
              "application/json",
              'Content-Length: ' . strlen(json_encode$message)),
              'Referer: ' . $_SERVER['REQUEST_URI'],
              "ip:" . $_SERVER['REMOTE_ADDR'],
              "msgMode" . $msgMode,
          ];

          curl_setopt($ch, CURLOPT_HTTPHEADER, $headers); //设置header
          $handles = curl_exec($ch);
          curl_close($ch);
          return $handles;
      }
  ```

  ​

* 服务端代码(HttpServer.php)

  ```php
  <?php
  class Server
  {
      private $http;
      public function __construct() {
          $this->http = new swoole_http_server("127.0.0.1", 9502);
  //        $this->http->set(
  //            array(
  //                'worker_num' => 16,
  //                'daemonize' => false,
  //                'max_request' => 10000,
  //                'dispatch_mode' => 0
  //            )
  //        );
          //$this->http->on('Start', array($this, 'onStart'));
          $this->http->on('request' , array( $this , 'onRequest'));
          $this->http->start();
      }
      public function onStart( $serv ) {
          echo "Start\n";
      }
      public function onRequest($request, $response) {
      	print_r($request->rawContent());//获取客户端提交的信息
      	//在这里自己实现日志的存取
      }
      public function onMessage($request, $response) {
          echo $request->message;
      }
  }
  new Server();
  ?>
  ```

  ​

* 启动服务

  ```
  /usr/bin/php HttpServer
  ```

  ​


