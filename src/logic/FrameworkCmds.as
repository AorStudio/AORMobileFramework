//logic::FrameworkCmds
package logic {

	import flash.display.DisplayObjectContainer;
	import flash.display.StageDisplayState;
	import flash.ui.Mouse;
	
	import entry.AORFWEntry;
	
	import org.air.AORFileWorker;
	import org.air.AorAIRbase;
	import org.air.enu.RWLOCEnu;

	//import org.basic.Aorfuns;

	public class FrameworkCmds {
		
		public function get $ ():AORFWEntry {
			return AORFWEntry.$;
		}
		
		public function FrameworkCmds(){
		}
		
		public var info_loginResponse:String = "loginResponse \n解释：为Server开放一个接口，在登陆Server（AORSCServer）成功后，server会通过此接口为本机设置一个用于验证的session信息。*** 注意：本机请勿调用此接口，否则可能影响程序网络正常的数据连接。"
		public function loginResponse (...args):void {
			if(args.length == 1){
				if($.socketManager){
					$.socketManager.session = args[0];
				}
			}
		}
		
		public var info_cfg:String = "cfg \n解释:查看 AORFWEntry.cfg 中的xml内容或者删除/写入config/appCfg.xml数据到应用数据暂存区\n用法:cfg info|del|save\n\tinfo\t查看AORFWEntry.cfg中的xml数据内容\n\tdel/delete/-\t删除已经写入存储区域的config/appCfg.xml文件\n\tsave/s/+\t将config/appCfg.xml文件写入应用指定存储区,之前的数据将会被覆盖\n";
		public function cfg (...args):void {
			if(args.length > 0){
				
				var $com:String = args.join(" ").toLowerCase();
				if($com == "info" || $com == "i"){
					$.console.echo('cfg info \>\n' + $.cfg + "\n");
				}else if($com == "del" || $com == "delete" ||  $com == "-"){
					AORFileWorker.deleteFile('config/appCfg.xml',RWLOCEnu.STORAGE);
					$.console.echo('<command> delCFG for RWLOCEnu.STORAGE!');
					$.console.nextCommand();
				}else if($com == "save" || $com == "s" || $com == "+"){
					AORFileWorker.writeXMLFile('config/appCfg.xml',$.cfg, RWLOCEnu.STORAGE);
					$.console.echo('<command> saveCFG for RWLOCEnu.STORAGE!');
					$.console.nextCommand();
				}else{
					$.console.echo('<command> sendToClient : illegal option  :: ' + args.join(' '));
				}
				
			}else{
				$.console.echo('<command> sendToClient : illegal option  :: ' + args.join(' '));
			}
		}
		
		public var info_mouse:String = "mouse \n解释:查看/编辑mouse是否是隐藏状态,修改此属性将写入config/appCfg.xml\n用法:mouse info|hide|show\n\tinfo/i\t查看mouse是否是隐藏状态\n\thide/h/-\t隐藏鼠标\n\tshow/s/+\t显示鼠标\n\n注意:该指令为动态修改config.xml相应的数据记录(config.xml/mouse/mouseHide节点)\n";
		public function mouse (...args):void {
			if(args.length > 0){
				
				var $com:String = args.join(" ").toLowerCase();
				if($com == "info" || $com == "i"){
					$.console.echo('mosue info \>\n' + (String($.cfg.mouse.mouseHide).toLowerCase() == "true" ? "HIDE" : "SHOW" ) + "\n");
				}else if($com == "hide" || $com == "h" ||  $com == "-"){
					$.cfg.mouse.mouseHide = "true";
					Mouse.hide();
					AORFileWorker.writeXMLFile('config/appCfg.xml',$.cfg, RWLOCEnu.STORAGE);
					$.console.echo('<command> mosue hide!');
					$.console.nextCommand();
				}else if($com == "save" || $com == "s" || $com == "+"){
					$.cfg.mouse.mouseHide = "false";
					Mouse.show();
					AORFileWorker.writeXMLFile('config/appCfg.xml',$.cfg, RWLOCEnu.STORAGE);
					$.console.echo('<command> mosue show!');
					$.console.nextCommand();
				}else{
					$.console.echo('<command> mosue : illegal option  :: ' + args.join(' '));
					$.console.nextCommand();
				}
				
			}else{
				$.console.echo('<command> mosue : illegal option  :: ' + args.join(' '));
				$.console.nextCommand();
			}
		}
		
		public var info_echo:String = "echo >\n解释:向console控件输出指定的文本数据\n用法:echo <text>";
		public function echo (...args):void {
			$.console.echo('LogicManager.say : ' + args.join(' '));
			$.console.nextCommand();
		}
		public var info_send:String = "send >\n解释:向Server发送文本数据,依赖于socketManager组件,如果socketManager组件为开启,将会得到SocketManager is not installed!的提示\n用法:send <text>";
		public function send (...args):void {
			var $sendStr:String;
			if($.socketManager == null){
				$.console.echo('LogicManager.send : SocketManager is not installed! ');
				$.console.nextCommand();
				return;
			}
			if(args.length > 0){
				$sendStr = args.join(' ');
				$.console.echo('LogicManager.send : ' + $sendStr);
				if($.socketManager.session == null){
					$.socketManager.sendRequest($sendStr + "|");
				}else{
					$.socketManager.sendRequest($.socketManager.session + " " + $sendStr + "|");
				}
			}else{
				$.console.echo('LogicManager.send : illegal option  :: ' + args.join(' '));
			}
			$.console.nextCommand();
		}
		public var info_sendToClient:String = "sendToClient >\n解释:向某个已经连上此应用(此应用充当Server端,依赖于ServerSocketManager组件,如果ServerSocketManager组件为开启,则会得到ServerSocketManager is not installed!的提示)的客户端发送文本数据\n用法:sendToClient <ip:String> <port:uint> <text>"
		public function sendToClient (...args):void {
			var $sendStr:String;
			if($.socketServerManager == null){
				$.console.echo('<command> sendToClient : ServerSocketManager is not installed! ');
				$.console.nextCommand();
				return;
			}
			if(args.length > 2){
				var $stcIP:String = args.shift();
				var $stcPort:uint = uint(args.shift());
				$sendStr = args.join(' ');
				$.console.echo('<command> sendToClient : [' + $stcIP + ':' + $stcPort + ']' + $sendStr);
				$.socketServerManager.sendStringToSocket($sendStr + "|",$.socketServerManager.getSocket($stcIP,$stcPort));
			}else{
				$.console.echo('<command> sendToClient : illegal option  :: ' + args.join(' '));
			}
			$.console.nextCommand();
		}
		public var info_sendToALLClient:String = "sendToAllClient >\n解释:向所有已经连接上此应用(此应用充当Server端,依赖于ServerSocketManager组件,如果ServerSocketManager组件为开启,则会得到ServerSocketManager is not installed!的提示)的客户端发送文本信息(广播)\n用法:sendToALLClient <text>";
		public function sendToALLClient (...args):void {
			var $sendStr:String;
			if($.socketServerManager == null){
				$.console.echo('<command> sendToClient : ServerSocketManager is not installed! ');
				$.console.nextCommand();
				return;
			}
			if(args.length > 0){
				$sendStr = args.join(' ');
				$.console.echo('<command> sendToALLClient :' + $sendStr);
				$.socketServerManager.sendStringToALL($sendStr + "|");
			}else{
				$.console.echo('<command> sendToALLClient : illegal option  :: ' + args.join(' '));
			}
			$.console.nextCommand();
		}
		public var info_server:String = "server >\n解释:如果此应用开启了ServerSocketManager组件,则可以使用此命令对其进行配置\n用法:server info|start|stop|change <ip> <port>\n\tinfo\t查看已配置ip&port\n\tstart\t开启ServerSocket\n\tstop\t关闭ServerSocket\n\tchange\t更换ip&port\n\n注意:该指令为动态修改config.xml相应的数据记录(config.xml/network/server/*节点)\n";
		public function server (...args):void {
			var $sendStr:String;
			if($.socketServerManager == null){
				$.console.echo('<command> server : ServerSocketManager is not installed! ');
				$.console.nextCommand();
				return;
			}
			
			if(args.length < 1){
				$.console.echo('<command> server : illegal option ');
				$.console.nextCommand();
				return;
			}
			
			var $server_com:String = args.shift();
			switch ($server_com){
				case 'start':
					$.socketServerManager.start();
					$.console.nextCommand();
					return;
				case 'stop':
					$.socketServerManager.stop();
					$.console.nextCommand();
					return;
				case 'change':
					if(args.length != 2){
						$.console.echo('<command> server : illegal option :: ' + $server_com + ' - ' + args.join(' '));
						$.console.nextCommand();
						return;
					}
					$.socketServerManager.Bind_IP = args[0];
					$.socketServerManager.Bind_localPort = args[1];
					$.console.echo('<command> server : change IP & Port :: ' + args[0] + ' : ' + args[1]);
					$.cfg.network.server.ip = String(args[0]);
					$.cfg.network.server.port = String(args[1]);
					$.console.dispatchCommand("cfg save");
					return;
				case 'info':
					$.console.echo('<command> server listenTo :  IP : ' + $.socketServerManager.Bind_IP + ' , Port : ' + $.socketServerManager.Bind_localPort);
					$.console.nextCommand();
					return;
				default:
					$.console.echo('<command> server : illegal option  :: ' + $server_com);
			}
			$.console.nextCommand();
		}
		public var info_socket:String = "socket >\n解释:如果此应用开启了SocketManager组件,则可以使用此命令对其进行配置\n用法:socket info|start|stop|change <ip> <port>\n\tinfo\t查看已配置ip&port\n\tstart\t开启socket连接\n\tstop\t关闭socket连接\n\tchange\t更换ip&port\n\n注意:该指令为动态修改config.xml相应的数据记录(config.xml/network/socket/*节点)\n";
		public function socket (...args):void{
			
			if($.socketManager == null){
				$.console.echo('LogicManager.socket : SocketManager is not installed! ');
				$.console.nextCommand();
				return;
			}
			
			if(args.length < 1){
				$.console.echo('LogicManager.socket : illegal option ');
				$.console.nextCommand();
				return;
			}
			
			var $socket_com:String = args.shift();
			switch ($socket_com){
				case 'start':
					$.socketManager.StartConnect();
					$.console.nextCommand();
					return;
				case 'stop':
					$.socketManager.stop();
					$.console.nextCommand();
					return;
				case 'change':
					if(args.length != 2){
						$.console.echo('LogicManager.socket : illegal option :: ' + $socket_com + ' - ' + args.join(' '));
						$.console.nextCommand();
						return;
					}
					$.socketManager.Host = args[0];
					$.socketManager.Port = args[1];
					$.console.echo('LogicManager.socket : change IP & Port :: ' + args[0] + ' : ' + args[1]);
					$.cfg.network.socket.ip = String(args[0]);
					$.cfg.network.socket.port = String(args[1]);
					//Aorfuns.log('NewXML > \n ' + xml.toString());
					AORFileWorker.writeXMLFile('config/appCfg.xml',$.cfg,RWLOCEnu.STORAGE);
					$.console.nextCommand();
					return;
				case 'info':
					$.console.echo('LogicManager.connectTo :  IP : ' + $.socketManager.Host + ' , Port : ' + $.socketManager.Port);
					$.console.nextCommand();
					return;
				default:
					$.console.echo('LogicManager.socket : illegal option  :: ' + $socket_com);
			}
			$.console.nextCommand();
		}
		public var info_loadPage:String = "loadPage >\n解释:框架内置的装载页面的方法(页面是一个继承自page::BasePage的子类)\n用法:loadPage <pageClassName> [fi|fbi|ttl|ttr|ttt|ttb] [动画时长(帧数):int]\n\tfi\t渐隐方式\n\tfbi\t插黑淡入淡出方式\n\tttl\t从左边滚动屏幕\n\tttr\t从右边滚动屏幕\n\tttt\t从上边滚动屏幕\n\tttb\t从下边滚动屏幕\n\t\n\t动画时长(帧数)\t规定此载入动画的持续时长";
		public function loadPage (...args):void {
			if(args.length < 1){
				$.console.echo('LogicManager.loadPage : illegal option ');
				return;
			}
			var $loadPageComStr:String = args.join(' ');
			$.console.echo('LogicManager.loadPage : ' + $loadPageComStr);
			$.tools.loadPage($loadPageComStr);
		}
		public var info_stage:String = "stageInfo >\n解释:用于查看stage的相关数据\n用法:stageInfo";
		public function stage (...args):void {
			
			
			if(args.length > 0){
				
				var $com:String = String(args[0]).toLowerCase();
				if($com == "info" || $com == "i"){
					
					var $outStr:String;
					$outStr = 'stage info : \n\tstageWidth = ' + $.stage.stageWidth + ' , stageHeight = ' + $.stage.stageHeight + '\n';
					$outStr += '\t$.display : x = ' + $.display.x + ' , y = ' + $.display.y + '\n';
					$outStr += '\t$.displayMask : x = ' + $.displayMask.x + ' , y = ' + $.displayMask.y + ' ,width = ' + $.displayMask.width + ' , height = ' + $.displayMask.height +'\n';
					$.console.echo($outStr);
					$.console.nextCommand();
					
				}else if($com == "fullscreen" || $com == "f" || $com == "+") {
					$.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
				}else if($com == "normal" || $com == "n" || $com == "-"){
					$.stage.displayState = StageDisplayState.NORMAL;
				}else if($com == "background" || $com == "b"){
					if(args.length > 1){
						
						var $nc:uint = uint(args[1]);
						
						$.stage.color = $nc;
						$.console.echo('<command> stage background color change to : 0x' + $nc.toString(16));
					}else{
						$.console.echo('<command> stage : illegal option  :: ' + args.join(' '));
						$.console.nextCommand();
					}
				}else{
					$.console.echo('<command> stage : illegal option  :: ' + args.join(' '));
					$.console.nextCommand();
				}
				
			}else{
				$.console.echo('<command> window : illegal option  :: ' + args.join(' '));
				$.console.nextCommand();
			}
			
		}
		public var info_AIRs:String = "AIRs/AIRsupport >\n解释:用于检测AIR在此设备上的相关支持数据\n用法:AIRs";
		public function AIRs ():void {
			AIRsupport();
		}
		public var info_AIRsupport:String = "AIRs/AIRsupport >\n解释:用于检测AIR在此设备上的相关支持数据\n用法:AIRsupport";
		public function AIRsupport ():void {
			$.console.echo('LogicManager.stageInfo : AIRsupport > \n ' + AorAIRbase.getInstance($).checkNativeApplicationSupports());
			$.console.nextCommand();
		}
		public var info_exit:String = "exit >\n解释:退出应用(注意,此命令在Android/IOS平台上无效)\n用法:exit";
		public function exit ():void {
			$.tools.AppExit();
		}
		
		public var info_newTracer:String = "newTracer >\n解释:创建实时数据监视窗口\n用法:newTracer <[[<label>,<objPath>,<paramName>],...]> [x] [y] [contentObject]";
		public function newTracer (...args):void {
			if(args.length < 1){
				$.console.echo('<command> newTracer : illegal option ::' + args.join(' '));
				$.console.nextCommand();
				return;
			}
			
			var $traceArray:Array = [];
			var $x:Number = 0,$y:Number = 0;
			var $contentObject:DisplayObjectContainer;
			
			//建立$traceArray
			
			var $taStr:String = args[0];
			
			$taStr = $taStr.substring(1,$taStr.length - 1);
			if($taStr.search(/\],\[/g) != -1){
				$taStr = $taStr.replace(/\],\[/g,']|[');
				var $tdList:Array = $taStr.split('|');
				
				var i:int,length:int = $tdList.length;
				
				for (i = 0; i < length; i++){
					
					nt_buildData($tdList[i],$traceArray);
					
				}
			}else{
				//$taStr
				nt_buildData($taStr,$traceArray);
			}
			
			if(args.length >= 4 ){
				$contentObject = nt_getTraceDataTarget(args[3]) as DisplayObjectContainer;
			}
			
			if(args.length >= 3){
				$y = Number(args[2]);
			}
			
			if(args.length >= 2){
				$x = Number(args[1]);
			}
			
			$.tools.createTracePanel($traceArray,$x,$y,$contentObject);
			
		}
		
		private function nt_buildData ($taStr:String,$ta:Array):void {
			if($taStr == "[mem]" || $taStr == "mem" || $taStr == "[MEM]" ||$taStr == "MEM" || $taStr == "[memory]" || $taStr == "memory"){
				$ta.push(["PrivateMemory",null,"PrivateMemory"]);
				$ta.push(["RunTimeMemory",null,"RunTimeMemory"]);
			}else if($taStr == "[fps]" || $taStr == "[FPS]" || $taStr == "fps" || $taStr == "FPS") {
				$ta.push(["FPS",null,"FPS"]);
			} else {
				$ta.push(nt_getTraceData($taStr));
			}
		}
		
		private function nt_getTraceData (ins:String):Array {
			ins = ins.substring(1,ins.length - 1);
			var $taStrArr:Array = ins.split(',');
			var $obj:Object = nt_getTraceDataTarget($taStrArr[1]);
			return [$taStrArr[0],$obj,$taStrArr[2]];
		}
		
		private function nt_getTraceDataTarget (ins:String):Object {
			var idA:Array = ins.split('.');
			var i:int = 0;
			return nt_getObject(idA,i);
		}
		
		private function nt_getObject(idxArray:Array, $i:int, $obj:Object = null):Object{
			
			var $next:int;
			var $newObj:Object;
			if($obj){
				if($i >= idxArray.length){
					return $obj;
				}else{
					$next = $i + 1;
					$newObj = $obj[idxArray[$i]] as Object;
					if($newObj){
						return nt_getObject(idxArray,$next,$newObj);
					}else{
						throw new Error ("<command> newTracer Error > can not find Object by this string : " + idxArray.join('.'));
						return null;
					}
				}
			}else{
				if(idxArray[0] == '$'){
					$next = $i + 1;
					$newObj = $ as Object;
					return nt_getObject(idxArray,$next,$newObj);
				}else{
					throw new Error ("<command> newTracer Error > can not find Object by this string : " + idxArray.join('.'));
					return null;
				}
			}
			return null;
		}
		
	}
}