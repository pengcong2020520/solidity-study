## 智能合约
### CRUD合约
开发三部曲：
* 引入Fisco bcos官方提供的Table.sol合约。
	* Table.sol合约包含分布式存储专用的智能合约接口；
	* Table.sol合约是一个抽象接口合约，包含TableFactory,Entry,Entries，Condition合约。
	
	`import "./Table.sol"`

* 用到TableFactory合约，创建表
	* 创建TableFactory对象
	```
	address addr = 0x1001
	TableFactory tf = TableFactory(addr)
	```
	* 创建t_test表，表的主键名为name，其他字段名为item_id和item_name
	```
	int count = tf.CreateTable("t_test", "name", "item_id", "item_name")
	```
	
	注意：`CreateTable`执行完,会在区块链系统表里面存储设定的数据；当对t_test进行增删改查时，才会创建表格。
* 对表进行CRUD操作
	+ 以插入记录举例说明：
1.打开记录表
2.创建Entry对象，创建一条空记录；
3.设置Entry对象，设置记录的字段值；
4.调用Table的insert方法，插入记录，返回count值，值为1表示插入成功。
	+ 查询记录
	```
	Entries entries = table.select(name, condition);
	Entry entry = entries.get(i);
	username = entry.getBytes32("name");
	```
	+ 更新记录
	```
	condition.EQ("name", name);
	int count = table.updata(name, entry, condition);
	```
	+ 删除记录
	```
	int count = table.remove(name, condition);
	```
	
### 面向对象之抽象类和接口
solidity支持抽象合约和接口机制；
+ 如果一个合约存在未实现的方法，那么它就是抽象合约，例如ERC20，ERC721合约等都是属于抽象合约。
> 抽象合约无法被编译成功，但可以被继承。

+ 抽象合约可以被定义成一个接口
```solidity
interface Contract_Name{
//抽象方法
function send(uint256) public returns (bool);
}
```
接口类似于抽象合约，但不能实现任何函数

注意：
1.接口合约无法继承其他合约与接口
2.接口合约无法定义构造函数
3.接口合约无法定义变量
4.接口合约无法定义结构体
5.接口合约无法定义枚举

### 库（Library）
solidity也提供了库（Library）的机制，库具有以下特点：
* 用户可以像使用合约一样使用关键字Library来创建合约；
例如库合约：
```solidity
Library SafeMath {
function Add(uint256 a, uint256 b) external returns(uint256 b) {
	c = a + b;
	assert(c - b == a);
	return c;
	}
}
```

* 在其他合约使用库合约时，只需要调用即可；
并使用using A for B可用于附加库函数（从库A）到任何类型（B）。这些函数将接收到调用他们的对象作为第一个参数。
例如：
```
import "./SafeMath";
contract TestAdd{
	using SafeMath for uint256;
	function testSafeMathAdd(uint256) external returns（uint256 b) {
	b = safeMath.add(a);
	}
}
```

### 编写合约的规范

####保证状态完整，再做外部调用
一个函数应该分为以下三个部分：
+ Checks  参数验证
+ Effects 修改合约状态
+ Interaction 外部交互
其中在编写合约时，必须按上述步骤依次进行，其中Checks-Effects用于完成合约自身状态所有相关的工作，这样进行外部交互调用，黑客就无法利用不完整的状态进行攻击，提高了合约的安全性。

#### 禁止递归
由于递归在合约中存在严重的安全问题，使得黑客容易攻击合约。所以禁止递归也是解决重入攻击的有效方式。
举个例子：
```
modifier noReentrancy() {
require(!locked);
locked = true;
_;
locked = false;
}
```
通过一个locked的标识，使得如果该函数在使用时是无法再次被调用，这样有效防止了函数多次被调用的情况，也就避免了递归。

#### 可维护性
+ **数据与逻辑相分离**
该模式下，要求一个业务合约和一个数据合约相对应，且分开各自独立；
其中，
业务合约通过数据合约提供的数据，配合计算能力来完成业务逻辑的操作；
数据合约，用于存储数据，是一个稳定的合约，不能轻易被更改。
+ **分解合约功能**
在该模式下，需要将合约内的各个功能按类别放入到子合约中，每个子合约对应一个类别的功能。
+ **跟踪最新合约**
用一个专门的合约（例如Registry合约）跟踪子合约的每次升级情况，主合约可以通过查询此Registry合约，来取得最新的子合约地址。
代码示例如下：
```solidity
contract Registry {
    address current;
    address[] prevoious;  
    function updata(address newAddress) public {
        if (newAddress != current) {
                prevoious.push(current);
                current = newAddress;
        }
    }    
    function getCurrent() public view returns (address) {
        return current;
    }
}
```

