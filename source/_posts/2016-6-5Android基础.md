---
uuid: 105c01e0-bcd3-11ed-abae-3fce2bc8128b
title: Android基础
date: 2016-6-5
tags: [Android]
---

Android基础

<!--more-->

```
一、Activity *******************************
1.Activity生命周期(↖↑↗ ← → ↙↓↘)
--↓--onCreate();
--↓--onStart(); ←←←←←←↑
--↓--onResume();←←←↑  ↑
--↓-- 运行中    ↑  onRestart();
--↓--onPause(); →→→↑  ↑
--↓--onStop();
→→→→→→↑
--↓--onDestroy();

* 当第一次运行时会看到主Activity，主Activity可以通过Intent到其他的Activity进行相关操作。
* 当启动其他的Activity时当前的Activity将会停止，之前的Activity失去焦点，新的Activity会获取焦点
* 根据栈的先进后出原则，当按Back键时，当前这个Activity销毁，前一个Activity重新恢复，调用onResume
* 当按Home键退回到主界面时，会调用onStop，界面消失，重新进来会调用onRestart

2.设置页面
1)设置xml布局文件
setContentView(R.layout.xxx_xxx);
2)写View（LayoutParams一定要和父布局的一致）
TextView textView = new TextView(this);
LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,ViewGroup.LayoutParams.WRAP_CONTENT);
params.leftMargin = 10;
params.rightMargin = 10;
textView.setLayoutParams(params);
textView.setTextSize(20);
textView.setPadding(100,20,0,20);
// 左上右下
textView.setBackgroundColor(Color.parseColor("#D4D4D4"));

// setFrame(x - 60, y - 120, x + 60, y);
// ImageView设置在父布局中位置

3.关闭Activity
finish();

4.页面跳转及传值
1)单向传值：
* 放值
Intent intent = new Intent(TabSpec3Acty.this, TabSpec3GoActy.class);
intent.putExtra("intentFlag", 0);
intent.putExtra("title", "修改姓名");
startActivity(intent);
* 取值
Intent intent = getIntent();
int intentFlag = intent.getIntExtra("intentFlag",-1);
String title = intent.getStringExtra("title");

2)数值回调：
* 等值
startActivityForResult(intent, 0);
// 0是requestCode
* 放值
Intent intent = new Intent();
intent.putExtra("resultIntentFlag",intentFlag);
setResult(101,intent);
// 101是resultCode
finish();
* 取值
protected void onActivityResult(int requestCode, int resultCode, Intent intent) {}

5.Fragment
1)Fragment
--↓--onAttach();
--↓--onCreate();
--↓--onCreateView();
--↓--onActivityCreate();

--↓--onStart();
--↓--onResume();←←←↑
--↓-- 运行中    ↑
--↓--onPause(); →→→↑
--↓--onStop();

--↓--onDestroyView();
--↓--onDestroy();
--↓--onDetache();

2)主Activity继承FragmentActivity
3)获取事务处理，进行增加、替换、或者隐藏，最后提交
FragmentTransaction fts = getSupportFragmentManager().beginTransaction();
fts.add(R.id.content, tab1);
// 资源可以用FrameLayout，或者ViewPager
// fts.replace(R.id.content, tab1);
// 替换
fts.commit();
4)继承Fragment，重写onCreateView方法
public View onCreateView(LayoutInflater inflater,ViewGroup container,Bundle savedInstanceState) {
if(view == null){
view = inflater.inflate(R.layout.acty_test,container,false);
}
return view;
}
5)得到上下文
Context context = this.getActivity();
6)操作Activity里面的东西
((FrameActy)getActivity()).refreshPage();
7)当Fragment相互切换的时候，会调用onHiddenChanged
会先调用activity的onResume


二、Intent *******************************
1.定义
作为一种意图，Activity，Service和Broadcast Receiver这三种核心组件都需要使用Intent来激活
Intent包含组件名称、动作、数据、种类、额外和标记等内容
2.动作（setAction()和getAction()）
1)Activity：通常使用context.startActivity();启动
2)Broadcast：通常使用context.registerReceiver();启动
3.数据（setData()和getData()）
4.种类（addCategory()和removeCategory()）
5.额外（putExtra()和getExxxxtra()）

6.返回桌面
        Intent intent = new Intent();
        intent.setAction(Intent.ACTION_MAIN);
        intent.addCategory(Intent.CATEGORY_HOME);
        startActivity(intent);

7.拨打电话
        Intent intent = new Intent();
        intent.setAction(Intent.ACTION_CALL);
        intent.setData(Uri.parse("tel:"+"15951723371"));
        startActivity(intent);

8.打开网页
        Intent intent = new Intent();
        intent.setAction(Intent.ACTION_VIEW);
        intent.setData(Uri.parse("http://www.baidu.com"));
        startActivity(intent); 

三、事件处理 *******************************
1.按钮点击事件（setOnClickListener或者setOnLongClickListener）
        kaishi.setOnLongClickListener(new View.OnLongClickListener() {}); 
kaishi.setOnClickListener(new View.OnClickListener() {});

2.物理按键按下（重写onKeyDown()，返回值就是是否执行完毕）
1)屏蔽返回键
public boolean onKeyDown(int keyCode, KeyEvent event) {
if(keyCode == KeyEvent.KEYCODE_BACK){
return true;
}
return super.onKeyDown(keyCode, event);
}
3.触摸事件（重写onTouch()，返回值就是是否执行完毕）
1)触摸事件
public boolean onTouchEvent(MotionEvent event) {
switch (event.getAction()){
case MotionEvent.ACTION_DOWN:
downX = event.getRawX();
downY = event.getRawY();
break;
case MotionEvent.ACTION_MOVE:
// 监听拖动
moveX = event.getRawX();
moveY = event.getRawY();
break;
case MotionEvent.ACTION_UP:
// 监听滑动
upX = event.getRawX();
upY = event.getRawY();
x = upX - downX;
y = upY - downY;


if(y < 0 && Math.abs(y) >= Math.abs(x)){
Toast.makeText(this, "向上滑动", Toast.LENGTH_SHORT).show();
}else if(y > 0 && y >= Math.abs(x)){
Toast.makeText(this, "向下滑动", Toast.LENGTH_SHORT).show();
}else if(x > 0 && x > Math.abs(y)){
Toast.makeText(this, "向右滑动", Toast.LENGTH_SHORT).show();
}else if(x < 0 && Math.abs(x) > Math.abs(y)){
Toast.makeText(this, "向左滑动", Toast.LENGTH_SHORT).show();
}
break;
}
return true;
}

注：getX getRawX的区别
getX：是以widget左上角为坐标原点，计算的Ｘ轴坐标值
getRawX：是以屏幕左上角为坐标原点，计算的Ｘ轴坐标值


四、资源访问(不能大写，字 下数 命名) *******************************
1.字符串(string)
textView.setTextColor(getResources().getString(R.string.app_name));
android:text="@string/app_name"

2.颜色(color)：颜色值通过RGB和透明度Alpha表示，可以用#RGB、#ARGB、#RRGGBB、#AARRGGBB表示
textView.setTextColor(getResources().getColor(R.color.red));
android:textColor="@color/red"
        
3.尺寸(dimen)
textView.setTextSize(getResources().getDimension(R.dimen.margin));
android:textSize="@dimen/margin"

4.布局(layout)
* 布局中包含其他布局：
<include layout="@layout/acty_top"/>

5.数组(array)
1)类型：
<array>：普通类型数组
<integer-array>：整形数组
<string-array>：字符串数组
2)定义：
<integer-array name="asdf">
<item>111</item>
<item>222</item>
</integer-array>
3)使用：
int[] asdf =  getResources().getIntArray(R.array.asdf);
String[] qwer = getResources().getStringArray(R.array.qwer);

6.图片(drawable)
1).9图片的使用
2)虚拟图片
(1)两张图片切换
<selector xmlns:android="http://schemas.android.com/apk/res/android">
<item android:state_pressed="true" android:drawable="@drawable/sdf"/>
<item android:state_pressed="true" android:drawable="@drawable/sdf"/>
</selector>
(2)单一背景
<selector xmlns:android="http://schemas.android.com/apk/res/android">
<item>
<shape>
<solid android:color="#ffffff" />
<stroke android:width="1px" android:color="#C0BFB6" />
<corners android:radius="5px"/>
</shape>
</item>
</selector>
(3)去边
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
<item android:top="-2px">
<shape>
xxx
</shape>
</item>
</layer-list>

7.样式(style)
1)样式支持继承：优先使用子样式
2)定义：
<style name="title" parent="basic">
<item name="android:padding">10px</item>
<item name="android:gradientRadius">center</item>
</style>
3)使用：
style="@style/title"

8.主题(theme)
1)定义资源color，attr，style
<color name="color_gray">#3b3b3b</color>
<attr name="main_color_normal" format="reference|color"/>


<style name="ThemeBlue" parent="AppTheme">
<item name="main_color_normal">@color/color_blue</item>
</style>
2)自定义MyApplication类，继承Application，存放curThemeId值，并生成getter，setter方法
3)AndroidManifest文件，name实现MyApplication类，修改默认android:theme="@style/ThemeBlue"
4)修改主题
1.设置主题，要在setContentView方法之前
setTheme(((MyApplication) getApplication()).getCurThemeId());
2.向MyApplication里面放值
((MyApplication) getApplication()).setCurThemeId(curTheme);
3.页面重新创建
recreate();
5)其他
1.设置属性默认背景
android:background="?main_color_normal"
2.拿到资源颜色转
int color = context.getResources().getColor(colorArr[i]);
3.拿到属性默认颜色
int mainColor = Utils.getThemeColor(this,R.attr.main_color_normal,R.color.color_blue);
6)工具类
// dip转px
public static float dipToPx(Context context, float dipValue) {
float scale = context.getResources().getDisplayMetrics().density;
return dipValue * scale + 0.5f;
}
// px转dip
public static float pxToDip(Context context, float pxValue) {
float scale = context.getResources().getDisplayMetrics().density;
return pxValue / scale + 0.5f;
}
// 得到当前主题颜色
public static int getThemeColor(Context mContext, int attr, int defaultColor){
TypedArray array = mContext.obtainStyledAttributes(new int[]{attr});
return array.getColor(0, defaultColor);
} 
9.原始xml(xml)
建文件夹xml

=======================================================================================================================
==================================================分割线-高级==========================================================
=======================================================================================================================


五、图形图像处理 *******************************
1.常用绘图类
1)Paint（画笔）
paint = new Paint();
paint.setAntiAlias(true);
// 去锯齿
paint.setColor(Color.BLUE);
// 设置画笔颜色
paint.setStyle(Paint.Style.STROKE);
// 描边，填充的属性为 Paint.Style.FILL
paint.setStrokeWidth(3);
// 路径宽度
paint.setTextSize(18);
// 设置字体大小
2)Canvas（画图面板）
canvas.drawColor(Color.GRAY);
// 设置画布颜色
3)Bitmap（Bitmap类代表位图）
4)BitmapFactory（从不同数据源来解析、创建Bitmap对象）
Bitmap bitmap = BitmapFactory.decodeFile("/sdcard/picture/bccd/img01.jpg");
// 从路径解析Bitmap
Bitmap bitmap = BitmapFactory.decodeResource(getResources(),R.mipmap.ic_launcher);
// 从资源解析Bitmap
Bitmap bitmap = BitmapFactory.decodeStream(inputStream);
// 输入流解析Bitmap


2.绘制2D图像
1)绘制几何图形
canvas.drawPoint(100, 100, paint);
// 绘制点(坐标)
canvas.drawLine(10,10,40,40,paint);
// 绘制线(开始坐标，结束坐标)
canvas.drawCircle(10, 10, 12, paint);
// 绘制圆(圆心坐标，半径)
canvas.drawRect(10,10,50,50,paint);
// 绘制方(左上角坐标，右下角坐标)
canvas.drawOval(new RectF(0,0,100,60),paint);
// 绘制椭圆(左上角坐标，右下角坐标)

2)绘制文本
canvas.drawText("张三",10,460,paint);
// 绘制文本(左下角起始坐标)

3)绘制路径
Path path = new Path();
// 绘制路径
path.moveTo(30,0);
// 起始点
path.lineTo(0,44);
// 路径
path.lineTo(60,44);

path.close();  // 闭合路径，如果写了，就会闭合
canvas.drawPath(path,paint);

canvas.drawTextOnPath("xxx",path,0,0,paint);
// 沿着路径绘制文字

4)绘制图片
canvas.drawBitmap(bitmap, 100, 100, paint);
// 从指定点绘制位图(左上角坐标)

Rect src = new Rect(0, 0, 300, 500);
Rect dst = new Rect(50, 50, 350, 350);
canvas.drawBitmap(bitmap, src, dst, paint);
// 从源位图上挖取(0,0)到(300,500)的一块图像，然后绘制到(50,50)到(350,550)区域


3.逐帧动画
1)写配置文件anim_frame_panda，oneshot表示循环，默认为true，
<animation-list xmlns:android="http://schemas.android.com/apk/res/android"
android:oneshot="false">

<item  android:drawable="@mipmap/fat_po_f01" android:duration="60" />
</animation-list>
2)ImageView的Background属性设置为配置文件，或者在Java里面设
android:background="@anim/anim_frame_panda"
imageView.setBackgroundResource(R.anim.anim_frame_boom);
3)拿到ImageView的background，并强转为AnimationDrawable，并启动
AnimationDrawable animationDrawable = (AnimationDrawable) imageView.getBackground();
animationDrawable.start();
animationDrawable.stop();


4.补间动画
1)代码显示
(1)位移动画
TranslateAnimation translateAnimation = new TranslateAnimation(0, 400, 0, 200);
// x开始，x位移，y开始，y位移
translateAnimation.setDuration(1000);
// 执行动画时间
translateAnimation.setFillAfter(false);
// 是否停留在最后状态
translateAnimation.setRepeatCount(1);
// 设置重复次数，连同本身一共两次
translateAnimation.setRepeatMode(Animation.REVERSE);
// 反向执行
imageView.startAnimation(translateAnimation);
// 开始动画
(2)缩放动画
ScaleAnimation scaleAnimation = new ScaleAnimation(1.0f, 2.0f, 1.0f, 2.0f);
// x开始，x缩放，y开始，y缩放
scaleAnimation.setDuration(800);
// 执行动画时间
scaleAnimation.setRepeatCount(2);
// 设置重复次数，连同本身一共三次
scaleAnimation.setRepeatMode(Animation.REVERSE);
// 反向执行
imageView.startAnimation(scaleAnimation);
// 开始动画
(3)旋转动画
RotateAnimation rotateAnimation = new RotateAnimation(0, 360, 100, 100);
// 开始度数，旋转度数，圆心
rotateAnimation.setDuration(800);
// 执行动画时间
// rotateAnimation.setInterpolator(new LinearInterpolator());
//均匀速度改变
// rotateAnimation.setInterpolator(new AccelerateInterpolator());
//先慢后快
// rotateAnimation.setInterpolator(new DecelerateInterpolator());
//先快后慢
rotateAnimation.setInterpolator(new AccelerateDecelerateInterpolator());
//先慢后快
rotateAnimation.setStartTime(100);
//等待100ms执行
rotateIV.startAnimation(rotateAnimation);
// 开始动画 
(4)透明、渐变动画
AlphaAnimation alphaAnimation = new AlphaAnimation(0.1f, 1f);
// 开始透明度，结束透明度
alphaAnimation.setDuration(2000);
// 执行动画时间
alphaAnimation.setFillAfter(true);
// 是否停留在最后状态
alphaIV.startAnimation(alphaAnimation);


alphaAnimation.setAnimationListener(new Animation.AnimationListener() {});
// 设置监听
2)xml显示(新建directory -> anim)
(1)位移动画
<translate xmlns:android="http://schemas.android.com/apk/res/android"
android:fromXDelta="0"
android:fromYDelta="0"
android:toXDelta="400"
android:toYDelta="100"
android:duration="1000">
</translate>
TranslateAnimation translateAnimation = (TranslateAnimation) AnimationUtils.loadAnimation(this,R.anim.anim_translate);
(2)缩放动画
<scale xmlns:android="http://schemas.android.com/apk/res/android"
android:fromXScale="1.0"
android:fromYScale="1.0"
android:toXScale="2.0"
android:toYScale="2.0"
android:pivotX="50%"
// 缩放圆心
android:pivotY="50%"

android:duration="1000">
</scale>
ScaleAnimation scaleAnimation = (ScaleAnimation) AnimationUtils.loadAnimation(this,R.anim.anim_scale);
(3)旋转动画
<rotate xmlns:android="http://schemas.android.com/apk/res/android"
android:duration="2000"
android:fillAfter="true"
android:fromDegrees="0"
android:pivotX="50%"
android:pivotY="50%"
android:toDegrees="720">
</rotate>
RotateAnimation rotateAnimation = (RotateAnimation) AnimationUtils.loadAnimation(this,R.anim.anim_rotate);
(4)透明、渐变动画
<alpha xmlns:android="http://schemas.android.com/apk/res/android"
android:duration="3500"
android:fromAlpha="0.1"
android:toAlpha="1"
android:fillAfter="true">
</alpha>
AlphaAnimation alphaAnimation = (AlphaAnimation) AnimationUtils.loadAnimation(this,R.anim.anim_alpha);
3)页面平滑动画
(1)写四个动画(anim_left_out)
<translate xmlns:android="http://schemas.android.com/apk/res/android"
android:fromXDelta="0"
android:toXDelta="-100%"
android:duration="400">
</translate>
(2)onCreate方法里面写
overridePendingTransition(R.anim.anim_right_in, R.anim.anim_left_out);
// 动画进来的效果，动画出去的效果
(3)finish方法里面写
overridePendingTransition(R.anim.anim_left_in, R.anim.anim_right_out);


六、多媒体应用 *******************************
1.MediaPlayer播放音频 ↖↑↗ ← → ↙↓↘
1)MediaPlayer周期
new()或reset() →  → setDataSource() →  → prepare() →  → start()
如果调用create()，会直接进入准备状态

2)主要方法
mediaPlayer.reset();
// 重置资源
mediaPlayer.setDataSource();
// 设置播放资源
mediaPlayer.prepare();
// 准备
mediaPlayer.start();
// 开始
mediaPlayer.pause();
// 暂停
mediaPlayer.stop();
// 停止
mediaPlayer.release();
// 释放资源

mediaPlayer.getDuration();
// 得到播放时间
mediaPlayer.seekTo();
// 从哪边开始播放
mediaPlayer.getCurrentPosition();
// 得到当前位置

2.SoundPool播放音频
3.VideoView播放视频
4.用MediaPlayer和SurfaceView播放视频


七、线程 *******************************
1.多线程
1)线程创建
Thread thread = new Thread(new Runnable() {});

2)线程开启
thread.start();

3)线程休眠
thread.sleep(200);

2.Handle消息传递
1)Handle作用
(1)在子线程与主线程进行通信
(2)在主线程中操作UI控件

2)Handle创建，并实现handleMessage接受消息
Handler handler = new Handler(){
public void handleMessage(Message msg) {
}
};

3)发送消息给handle
handler.sendMessage(message);
// 发送带有Message的消息
handler.sendEmptyMessage(0x12);
// 发送一个空的信息

4)Message
Message message = Message.obtain();
message.arg1 = 1;
message.arg2 = 1;
message.obj = obj;
message.what = 0x12;


八、数据存储
　　1.SharedPreference（xml文件）：用于存储较简单的数据
1)定义并设权限
SharedPreferences spf = getSharedPreferences("user",Activity.MODE_PRIVATE);

2)放值
spf.edit()
spf.putString("name","张三")
spf.commit();

3)取值
String name = spf.getString("name","");

4)清空
spf.edit()
spf.clear()
spf.commit();

　　2.File（文件）：用于存储大数量的数据，缺点是更新数据困难
1)文件读取
            FileInputStream fis = this.openFileInput(FILE_NAME);
            byte[] buff = new byte[1024];
            int hasRead = 0;
            StringBuilder sb = new StringBuilder("");
            while ((hasRead = fis.read(buff)) > 0) {
                sb.append(new String(buff, 0, hasRead, "utf-8"));
            }

2)文件写入
            FileInputStream fis = this.openFileInput(FILE_NAME);
            byte[] buff = new byte[1024];
            int hasRead = 0;
            StringBuilder sb = new StringBuilder("");
            while ((hasRead = fis.read(buff)) > 0) {
                sb.append(new String(buff, 0, hasRead, "utf-8"));
            }
　
3.SQLite（轻量级数据库）：支持基本SQL语法，是常被采用的一种数据存储方式
1)创建连接以及创表类，继承SQLiteOpenHelper
private static String dbName = "data.db";
private static int version = 1;
public final static String T_USER = "t_user";


public DataDBHelper(Context context){
super(context,dbName,null,version);
}
// 创建数据表，只在第一次运行的时候执行
@Override
public void onCreate(SQLiteDatabase db) {
StringBuffer createTableSql = new StringBuffer("");
createTableSql.append(" create table if not exists " + T_NOTE + " ");
createTableSql.append(" ( ");
createTableSql.append(" _id integer primary key autoincrement,");
createTableSql.append(" name varchar, ");
createTableSql.append(" ) ");


db.execSQL(createTableSql.toString());
}
// 更新数据库，新版本号比老版本号高的时候更新数据表
@Override
public void onUpgrade(SQLiteDatabase sqLiteDatabase, int oldVersion, int newVersion) {
sqLiteDatabase.execSQL("drop table " + T_NOTE);
onCreate(sqLiteDatabase);
}

2)写增删改查类
// 类型定义
private SQLiteHelper sqliteHelper;
public SQLiteDBManager(Context context) {
if (sqliteHelper == null) {
sqliteHelper = new SQLiteHelper(context);
}
}

// 增删改
SQLiteDatabase db = sqliteHelper.getWritableDatabase();
db.execSQL(sql, new Object[]{});
db.close();

// 查
SQLiteDatabase db = sqliteHelper.getReadableDatabase();
Cursor cursor = db.rawQuery(sql, null);
while (cursor.moveToNext()) {
cursor.getInt(cursor.getColumnIndex("_id"));
}
cursor.close();
db.close();

// 包装类增、删、改
ContentValues cv = new ContentValues();
cv.put("_id", this.queryMaxId());
db.insert("table_name", null, cv);

db.delete("table_name", " _id = ? ", new String[]{String.valueOf(item.getId())});


ContentValues cv = new ContentValues();
cv.put("_id", item.getId());
db.update("table_name", cv, " _id = ? ", new String[]{String.valueOf(item.getId())});







九、Service *******************************
1)生命周期
(1)启动 (2)绑定
-↓-onCreate();
-↓-onCreate();
-↓-onStartCommand();
-↓-onBind();
-↓-onDestroy();
-↓-onUnBind();
-↓-onDestroy();


2)注册Service
        <service android:name=".MyService">
            <!-- 优先级[-1000,1000] -->
            <intent-filter android:priority="900">
                <action android:name="com.suwei.someaction" />
            </intent-filter>
        </service>


3)启动Service
Intent intent = new Intent("com.suwei.someaction");

startService(intent);
stopService(intent);

4)绑定Service
        Intent intent = new Intent(mContext, MyService.class);
// 绑定或解绑
        bindService(intent, conn, Service.BIND_AUTO_CREATE);
unbindService(conn);

// ServiceConnection匿名链接对象
private MyService myService;
private ServiceConnection conn = new ServiceConnection() {
@Override
public void onServiceConnected(ComponentName componentName, IBinder iBinder) {
MyService.MyBind bind = (MyService.MyBind) iBinder;
myService = bind.getMyService();
}
@Override
public void onServiceDisconnected(ComponentName componentName) {
}
};

// Service的onBind方法每次return新的MyBind对象
@Override
public IBinder onBind(Intent intent) {
return new MyBind();
}

public class MyBind extends Binder {
public MyService getMyService() {
return MyService.this;
}
}


十、Broadcast *******************************
1.注册方法
1)静态注册(继承BroadcastReceiver)
<receiver android:name=".FirstReceive">
<!-- 优先级[-1000,1000] -->
<intent-filter android:priority="998">
<action android:name="qqq"/>
<category android:name="android.intent.category.DEFAULT"/>
</intent-filter>
</receiver>
2)动态注册(可以使用匿名对象或者类继承BroadcastReceiver)
private BroadcastReceiver receiver = new BroadcastReceiver() {
@Override
public void onReceive(Context context, Intent intent) {
String action = intent.getAction();
if ("name".equals(action)) {
Log.e("收到广播", "=========修改名字为========= " + intent.getStringExtra("name"));
} else if ("age".equals(action)) {
Log.e("收到广播", "=========修改年龄为========= " + intent.getStringExtra("age"));
} else if ("sex".equals(action)) {
Log.e("收到广播", "=========修改性别为========= " + intent.getStringExtra("sex"));
}
}
};
IntentFilter intentFilter = new IntentFilter();
intentFilter.addAction("name");
intentFilter.addAction("age");
intentFilter.addAction("sex");

// 注册receive
registerReceiver(receiver, intentFilter);
// 解注册receive
unregisterReceiver(receiver);

2.分类
1)普通广播
Intent intent = new Intent();
intent.setAction("receive_action1");
intent.putExtra("name","张三");
sendBroadcast(intent);
2)有序广播(等前一个接受者处理完后才会发送给后一个接受者)
intent = new Intent();
intent.setAction("receive_action2");
intent.putExtra("kkk", "111");
sendOrderedBroadcast(intent, null);

// 截断广播
abortBroadcast();

// 前一个receive放其他的值
Bundle bundle = new Bundle();
bundle.putString("msg","第一个页面的信息");
setResultExtras(bundle);

// 后一个receive取值
String msg = getResultExtras(true).getString("msg");
3.系统广播
// 时间改变广播(只能动态注册)
SystemChangeReceive systemChangeReceive = new SystemChangeReceive();
IntentFilter filter = new IntentFilter();
filter.addAction(Intent.ACTION_TIME_TICK);
registerReceiver(systemChangeReceive, filter);

// 网络状态广播(动态静态都可以)
NetChangeReceive netChangeReceive = new NetChangeReceive();
IntentFilter filter = new IntentFilter();
filter.addAction("android.net.conn.CONNECTIVITY_CHANGE");
registerReceiver(netChangeReceive, filter);

十一、ContentProvider *******************************
1.ContentResolver
Cursor cursor = context.getContentResolver().query(
uri,     // uri
null,   // 需要查询的字段String[]{}
null,   // 查询条件，可设?
null,   // 查询条件的参数，String[]{}
null      // 排序
);





// ========================================== Android体系结构（从上到下分为4层） ==========================================
	Android应用层
	Android应用框架层
	Android系统运行层
	Linux内核层
	
	
// ========================================== android四大组件 ==========================================
	Activity
	Service
	Broadcast Receiver
	Content Provider

	
// ========================================== ANR（Application No Response） ==========================================
	程序无响应的错误信息。（5秒）


// ========================================== OOM（out of memory） ==========================================
	内存溢出


// ========================================== 像素关系 ==========================================
	px: 像素
	dpi: 对角线像素/尺寸
	dp:(px*160)/dpi
	ppi: 针对显示器 ppi=dpi
	

// ========================================== 沉浸式状态栏 ==========================================
	android:fitsSystemWindows="true"
	android:clipToPadding="true"

	if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
				getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
	//透明状态栏
				getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);
	//透明导航栏
	}
	this.requestWindowFeature(Window.FEATURE_NO_TITLE);



// ========================================== 设置drawable-top图片 ==========================================
	textView.setCompoundDrawablesWithIntrinsicBounds(null, getResources().getDrawable(R.mipmap.tdi_yi), null, null);



// ========================================== 适配器 ==========================================
	1)ArrayAdapter（数组适配器）：只能绑定单一类型的数据
		ArrayAdapter<String> adapter = new ArrayAdapter<String>(
			TestActy.this,
			// 1.上下文
			android.R.layout.simple_list_item_1,
			// 2.布局文件
			new String[]{"name","sex"}
			// 3.数据源（可以是String数组，或者是List包含String）
		);
		spinner.setAdapter(adapter);

	2)SimpleAdapter（简单适配器）：可以显示比较复杂的数据
		SimpleAdapter simpleAdapter = new SimpleAdapter(
			TabSpec1Acty.this,
			// 1.上下文
			simpleList,  // 2.数据源（可以是List包含Map，或者是List包含其他）
			android.R.layout.simple_list_item_2,
			// 3.布局文件
			new String[]{"name","sex"},
			// 4.Map的键
			new int[]{android.R.id.text1,android.R.id.text2}
			// 5.布局控件的id
			);
		listView.setAdapter(simpleAdapter);

	3)BaseAdapter（自定义适配器）：
		public View getView(int i, View view, ViewGroup viewGroup) {
			ViewHolder holder;
				if(view != null && view.getTag() != null){
					holder = (ViewHolder) view.getTag();
				}else {
					holder = new ViewHolder();
					view = LayoutInflater.from(context).inflate(R.layout.item_resource,null);
					holder.textView1 = (TextView) view.findViewById(R.id.item_text1);
					view.setTag(holder);
				}

			Map<String,Object> singleMap = list.get(i);
			holder.textView1.setText(singleMap.get("name").toString());

			return view;
		}
		
		private static class ViewHolder{
			TextView textView1;
			TextView textView2;
		} 


// ========================================== 自定义View ==========================================
	1)继承View
	2)设置画布宽高（重写onMeasure方法，默认是全屏）
		protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
			super.onMeasure(widthMeasureSpec, heightMeasureSpec);
			// 决定画布宽高
			setMeasuredDimension(700,800);
		}

	3)绘图（重写onDraw方法）
	4)重绘
		invalidate();  // 主线程中
		postInvalidate(); // 子线程中

		
// ========================================== Notification通知 ==========================================
	1)显示系统通知
		builder = new Notification.Builder(context);
		builder.setTicker("提示内容");
		builder.setSmallIcon(R.mipmap.ic_launcher);
		// 显示的图标
		builder.setContentTitle("标题");
		builder.setContentText("内容");


		notification = builder.build();
		notification.flags = Notification.FLAG_AUTO_CANCEL;
		// 设置为可以取消
		notificationManager.notify(1, notification);
		// 第一个参数是notification的id，如果id一样，则覆盖
	2)带有页面跳转
		/**
		* 上下文，requestCode,页面跳转intent
		* PendingIntent.FLAG_CANCEL_CURRENT：新发和旧发不论requestCode是否一样，各自的值不变
		* PendingIntent.FLAG_UPDATE_CURRENT：新发和旧发的requestCode一样，则新的会覆盖旧的
		*/
		intent = new Intent(context, BActy.class);
		intent.putExtra("name","张三");
		pendingIntent = PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_CANCEL_CURRENT);
		builder.setContentIntent(pendingIntent);

		pendingIntent.getBroadcast(context,0,intent,0);
		// pendingIntent去发送广播
	3)自定义布局
		RemoteViews remoteViews = new RemoteViews(context.getPackageName(),R.layout.notification_item);
		remoteViews.setOnClickPendingIntent(R.id.notification_title,pendingIntent);
		// 设置内部点击
		remoteViews.setImageViewResource(R.id.notification_head,R.mipmap.ic_launcher);
		remoteViews.setTextViewText(R.id.notification_title,"标题");
		remoteViews.setProgressBar(R.id.notification_progressbar,100,12,false);

		builder.setContent(remoteViews);
		4)移除通知
		notificationManager.cancel(0);
		// 移除单个
		notificationManager.cancelAll();
		// 移除所有
		

// ========================================== 通过Terminal获取SHA1 ==========================================
	keytool -v -list -keystore  C:\Users\jmm\Desktop\key.keystore


// ========================================== android:windowSoftInputMode属性 ==========================================
【A】stateUnspecified：软键盘的状态并没有指定，系统将选择一个合适的状态或依赖于主题的设置
【B】stateUnchanged：当这个activity出现时，软键盘将一直保持在上一个activity里的状态，无论是隐藏还是显示
【C】stateHidden：用户选择activity时，软键盘总是被隐藏
【D】stateAlwaysHidden：当该Activity主窗口获取焦点时，软键盘也总是被隐藏的
【E】stateVisible：软键盘通常是可见的
【F】stateAlwaysVisible：用户选择activity时，软键盘总是显示的状态
【G】adjustUnspecified：默认设置，通常由系统自行决定是隐藏还是显示
【H】adjustResize：该Activity总是调整屏幕的大小以便留出软键盘的空间
【I】adjustPan：当前窗口的内容将自动移动以便当前焦点从不被键盘覆盖和用户能总是看到输入内容的部分

注：其中state和adjust是可以组合的，用 | 连接
	
	
	














一、通用属性
android:layout_weight="0|1"
* 权重，在线性布局中，如果设置为1，则最后摆放，且占领剩余空间
* 首先按照控件声明的尺寸进行分配，然后再将剩下的尺寸按weight分配
* 可在父容器中设置 android:weightSum="2" 来规定子控件总共的weight数量
* 宽度 = 本身宽度 + 剩余宽度根据权重平分


二、位置属性
1)子控件在本控件的位置，没有layout
android:padding="" 
内边距
android:gravity=""
子控件在本控件的位置

2)本控件在父控件的位置，有layout
android:layout_margin="" 
外边距

LinearLayout布局：
android:layout_gravity=""

RelativeLayout布局：
* 位置关系
android:layout_below="@id/xx"
在某元素的下边
android:layout_above="@id/xx"
在某元素的上边
android:layout_toLeftOf="@id/xx"
在某元素的左边
android:layout_toRightOf="@id/xx"
在某元素的右边

android:layout_centerHrizontal="t|f"
水平居中（父控件中）
android:layout_centerVertical="t|f"
垂直居中（父控件中）
android:layout_centerInparent="t|f"
完全居中（父控件中）


* 对齐关系
android:layout_alignTop="@id/xx"
本元素的上边缘和某元素的上边缘对齐
android:layout_alignLeft="@id/xx"
本元素的左边缘和某元素的左边缘对齐
android:layout_alignBottom="@id/xx"
本元素的下边缘和某元素的下边缘对齐
android:layout_alignRight="@id/xx"
本元素的右边缘和某元素的右边缘对齐

android:layout_alignParentBottom="t|f"
贴紧父元素的下边缘
android:layout_alignParentLeft="t|f"
贴紧父元素的左边缘
android:layout_alignParentRight="t|f"
贴紧父元素的右边缘
android:layout_alignParentTop="t|f"
贴紧父元素的上边缘
android:layout_alignWithParentIfMissing="t|f"
如果对应的兄弟元素找不到的话就以父元素做参照物

三、文本框，编辑框（TextView，EditText）
1)监听事件
editText.addTextChangedListener(new TextWatcher(){});
//文本改变事件
editText.setOnFocusChangeListener(new View.OnFocusChangeListener() {});
//焦点改变事件

2)属性
android:text=""
设置显示文字
android:autoLink="" 
设置超链接格式（一般用于TextView底部超链接）

android:editable="true"
是否可以编辑
android:password="true"
是否密码显示
android:lines="3"
文本编辑框行数（显示行数）
android:maxLines="3"
最大行数（数字行数）
android:maxLength="3"
限制输入字数
android:hint="asdf"
默认提示字
android:numeric="integer"
integer（正整数）、signed（整数）、decimal（浮点）
android:phoneNumber="true"
是否数字显示，弹数字键盘


android:digits="asdf"
过滤字符串
android:selectAllOnFocus="true"
获取焦点时是否选中自我
android:capitalize="cwj1987"
这样仅允许接受输入cwj1987，一般用于密码验证

android:imeOptions="actionNext"
输入法选项，移动到下一个输入框
android:imeOptions="actionDone"
输入法选项，关闭键盘
android:singleLine="true"
是否单行显示

3)密码明文密文显示
editText.setTransformationMethod(HideReturnsTransformationMethod.getInstance());
editText.setTransformationMethod(PasswordTransformationMethod.getInstance());

四、按钮，图片按钮，图片（Button、ImageButton、ImageView）
1)监听事件
button.setOnClickListener(new View.OnClickListener() {});
//点击事件
button.setOnTouchListener(new View.OnTouchListener() {
//按钮等触摸事件
public boolean onTouch(View view, MotionEvent motionEvent) {
switch (motionEvent.getAction()){
case MotionEvent.ACTION_DOWN:
break;
}
return true;
}
});

2)Button属性
android:background="@drawable/cal_edittext_bg"
android:drawableTop="@drawable/cal_edittext_bg"
android:drawablePadding="10dp"
android:onClick="onClick"

3)ImageButton属性
android:background="@drawable/cal_edittext_bg"
android:src="@drawable/cal_edittext_bg"
android:scaleType="fitXY"

4)ImageView属性
android:background="@drawable/cal_edittext_bg"
android:src="@drawable/cal_edittext_bg"
android:scaleType="fitXY"

* 默认：不缩放，左上角开始绘制图
* center：不缩放，图像放在ImageView中间（用于小图片按钮）
* centerCrop：等比缩放，图片完全覆盖ImageView
* centerInside：等比缩放，使图片完全显示
* fitXY：独立缩放，贴合ImageView

5)差异
* ImageButton不支持setText，而Button支持，ImageButton支持setImageURI，而Button不支持
* ImageButton有Button的状态，但是ImageView没有
* ImageButton拥有默认背景android:background="@android:drawable/btn_default"
* ImageButton支持9.png图片，ImageView不支持
* 点9图片需要放在drawable-hdpi里面

5.单选按钮，复选按钮，开关按钮（RadioGroup,RadioButton,CheckBox,ToggleButton）
1)监听事件
radioGroup.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {});
checkBox.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {});
toggleButton.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {});

2)属性
RadioGroup中的选中android:checkedButton="@+id/at_rb_rb1"
CheckBox中的选中android:checked="true"
ToggleButton就相当于CheckBox

6.日期控件，时间控件（DatePicker,TimePicker）
1)监听事件
datePicker.init(year, month, day, new DatePicker.OnDateChangedListener() {
@Override
public void onDateChanged(DatePicker datePicker, int year, int month, int day) {}
});
timePicker.setOnTimeChangedListener(new TimePicker.OnTimeChangedListener() {});

2)属性
android:startYear="2005"
android:endYear="2016"

3)日历类
Calendar calendar = Calendar.getInstance();
int year = calendar.get(Calendar.YEAR);
int month = calendar.get(Calendar.MONTH);
int day = calendar.get(Calendar.DAY_OF_MONTH);


7.滚动页面（ScrollView,HorizontalScrollView）
1)属性
android:scrollbars="none"
// 设置滚动条

android:orientation="vertical"
android:fillViewport="true"
注：ScrollView里面只能存在一个组件，而且是垂直摆放的


8.进度条，拖动条，评分条（ProgressBar,SeekBar,RatingBar）
1)监听事件
seekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {});
ratingBar.setOnRatingBarChangeListener(new RatingBar.OnRatingBarChangeListener() {});

2)ProgressBar属性
style="@android:style/Widget.ProgressBar.Inverse"
转圈圈
style="@android:style/Widget.ProgressBar.Horizontal"
水平样式
android:max="100"
最大值
android:progress="30"
进度

3)SeekBar属性
android:max="100"
最大值
android:progress="30"
进度
android:thumb="@mipmap/ic_launcher"
控制图片

4)RatingBar属性
android:numStars="5"
星星总数量
android:rating="3.5"
默认数量
android:stepSize="0.5"
最小步伐
style="?android:attr/ratingBarStyleSmall"
星星的样式

5)线程是滚动条滚动
// 关注点：线程里面不能直接处理控件
new Thread(new Runnable() {
public void run() {
for(int i = 0;i<=100;i++){
progressInt = i;
try {
Thread.sleep(100);
} catch (InterruptedException e) {
e.printStackTrace();
}
handler.sendEmptyMessage(0);
}
}
}).start();

// 用Handler处理接受的值
private Handler handler = new Handler(){
public void handleMessage(Message msg) {
switch (msg.what){
case 0:
progressBar.setProgress(progressInt);
break;
}
super.handleMessage(msg);
}
};

9.网页控件（WebView）
1)WebView设置
WebView webView = (WebView) findViewById(R.id.tabspec1_wv_wv1);
WebSettings webSettings = webView.getSettings();    // 获取设置
webSettings.setJavaScriptEnabled(true);             // 设置能执行js脚本
webSettings.setAllowFileAccess(true);               // 设置可以访问文件
webSettings.setBuiltInZoomControls(true);           // 设置支持缩放
webView.loadUrl("file:///android_asset/welcome.html");// 加载页面（建asset文件夹，与res同级）

//网页可在webView里面覆盖加载
webView.setWebViewClient(new WebViewClient(){
public boolean shouldOverrideUrlLoading(WebView view, String url) {
view.loadUrl(url);
return true;
}
});
2)返回键设置
public boolean onKeyDown(int keyCode, KeyEvent event) {
if ((keyCode == KeyEvent.KEYCODE_BACK) && webView .canGoBack()) { 
webView.goBack();
return true;
}
return false;
}

3)网络权限
<uses-permission android:name="android.permission.INTERNET" />


/**
 * ==============================以下应用适配器======================================
 */
10.画廊、图片选择（Gallery和ImageSwitcher）
1)监听事件
gallery.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {});
// gallery选择事件，一般用于画布设图片
gallery.setOnItemClickListener(new AdapterView.OnItemClickListener() {});
// gallery点击事件

2)Gallery属性
android:layout_width="match_parent"
android:unselectedAlpha="0.6"
android:spacing="4dp"


3)ImageSwitcher配置
imageSwitcher.setFactory(new ViewSwitcher.ViewFactory() {
public View makeView() {
ImageView imageView = new ImageView(TestActy.this);
imageView.setLayoutParams(new ImageSwitcher.LayoutParams(
ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT
));
imageView.setScaleType(ImageView.ScaleType.FIT_XY);
imageView.setBackgroundColor(0xff0000);
return imageView;
}
});
// 设置图片
imageSwitcher.setImageResource(imgInt[i]);

11.自动提示框，下拉框（AutoCompleteTextView和Spinner）
1)监听事件
spinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {});
autoCompleteTextView.setOnItemClickListener(new AdapterView.OnItemClickListener() {});

2)AutoCompleteTextView属性
android:completionHint="123"
提示标题
android:completionThreshold="2"
至少几个字符才会提示
android:dropDownWidth="match_parent"
下拉框宽度
android:dropDownHeight="wrap_content"
下拉框高度

3)Spinner获值和设值
spinner.getSelectedItemPosition();
spinner.setSelection(i);


12.网格（GridView）
1)监听事件
gridView.setOnItemClickListener(new AdapterView.OnItemClickListener() {});


2)属性
android:numColumns="4"
列数
android:verticalSpacing="10dp"
垂直间隔
android:horizontalSpacing="10dp"
水平间隔

13.列表（ListView）
1)监听事件
listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {});

2)属性
宽高需要 match_parent
android:listSelector="@android:color/transparent"
选中的背景色
android:divider="@null"
无分割线
android:scrollbars="none"
无滚动条
android:fadingEdge="none"
渐变区域的宽度
android:scrollingCache="false"
滚动缓存

3)ListView消息更新
1.更新适配器里的数据源
2.刷新适配器
myAdapter.notifyDataSetChanged();
3.ListView设置动态效果
listView.smoothScrollToPosition(0);


14.可展开的列表（ExpandableListView）
1)监听事件
expandableListView.setOnChildClickListener(new ExpandableListView.OnChildClickListener() {});

2)适配器配置
1.继承BaseExpandableListAdapter
2.用二维数组或者Item嵌套Item传递数据源

3)设置ExpandableListView默认显示图标为null
expandableListView.setGroupIndicator(null);

15.页面轮换器（ViewPager）
1)监听事件
viewPager.setOnPageChangeListener(new ViewPager.OnPageChangeListener() {});

2)适配器配置
1.继承PagerAdapter
2.重写方法
public void destroyItem(ViewGroup container, int position, Object object) {
container.removeView(imageViewList.get(position));
}
public Object instantiateItem(ViewGroup container, int position) {
container.addView(imageViewList.get(position),0);
return imageViewList.get(position);
}
public int getCount() {
return imageViewList.size();
}
public boolean isViewFromObject(View view, Object object) {
return view == object;
}

3)自定义选项卡设置页面
设置第几个选项：viewPager.setCurrentItem(0);

16.AlertDialog
1)普通AlertDialog
customDialog.setCanceledOnTouchOutside(false);
// dialog
(1)AlertDialog的创建
if(alertDialog == null){
AlertDialog.Builder builder = new AlertDialog.Builder(context);
// 建造者模式，用Builder内部类去建造
builder.setTitle("提示框");
builder.setIcon(R.mipmap.ic_launcher);
builder.setMessage("确定退出吗");
builder.setPositiveButton("确定", new DialogInterface.OnClickListener() {});
builder.setNegativeButton("取消", new DialogInterface.OnClickListener() {});
alertDialog = builder.create();

}
alertDialog.show();

(2)AlertDialog设置返回按钮，保证页面安全
@Override  
public boolean onKeyDown(int keyCode, KeyEvent event) {
//重写父类onKeyDown方法
switch (keyCode){
case KeyEvent.KEYCODE_BACK:
if(alertDialog != null && alertDialog.isShowing()){
alertDialog.dismiss();
return true;
}
showAlertDialog();
break;
}
return true;
}

2)单选（SingleChoice）
setSingleChoiceItems(new String[]{"篮球","足球","排球"}, 0, new DialogInterface.OnClickListener() {})

3)复选（MultiChoice）
setMultiChoiceItems(new String[]{"篮球","足球","排球"}, new boolean[]{false,false,false}, new DialogInterface.OnMultiChoiceClickListener() {})

4)类单选（Items）
builder.setItems(arr, new DialogInterface.OnClickListener() {});
// 和单选AlertDialog的区别是没有右边的单选按钮，且会有dismiss()效果

5)时间日期对话框
new DatePickerDialog(Context.this, new DatePickerDialog.OnDateSetListener() {},year,month,day_of_month).show();
new TimePickerDialog(Context.this, new TimePickerDialog.OnTimeSetListener() {},hour_of_day,minute,true).show();


6)进度条对话框
progressDialog1 = new ProgressDialog(mContext);
progressDialog1.setTitle("大片");
progressDialog1.setMessage("下载中。。。");
progressDialog1.setCancelable(false);
// 响应系统返回键的语句
progressDialog1.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL); // 圈圈格式ProgressDialog.STYLE_SPINNER
progressDialog1.setMax(100);
progressDialog1.show();

7)绑定自定义布局或控件
builder.setView(view);

8)自定义Dialog
1)自定义Dialog，继承Dialog
public MyCustomDialog(Context context) {
super(context,R.style.MyDialog);
setContentView(R.layout.dialog_listviewdialog);
titleTV = (TextView) findViewById(R.id.listviewdialog_tv_title);
listViewLV = (ListView) findViewById(R.id.listviewdialog_lv_main);
queDingBN = (Button) findViewById(R.id.listviewdialog_bn_queding);
}
2)实现style样式
style样式
<style name="MyDialog" parent="@android:style/Theme.Dialog">
<item name="android:windowFrame">@null</item>
<item name="android:windowContentOverlay">@null</item>
<item name="android:windowBackground">@android:color/transparent</item>
<item name="android:windowAnimationStyle">@android:style/Animation.Dialog</item>
</style>


9)自定义PopupWindow
popupWindow = new PopupWindow(view, ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
popupWindow.setFocusable(true);
// 可获取焦点
popupWindow.setBackgroundDrawable(new BitmapDrawable());
// 响应系统返回键的语句
//方法一：
popupWindow.showAsDropDown(findViewById(R.id.main_bn_anxia));
//方法一：
popupWindow.showAtLocation(findViewById(R.id.main_bn_anxia), Gravity.BOTTOM,0,0);


17.TabHost选项卡（弃用）：
1)布局
<TabHost xmlns:android="http://schemas.android.com/apk/res/android"
android:layout_width="fill_parent"
android:layout_height="fill_parent"
android:id="@android:id/tabhost"
>
<LinearLayout
android:layout_width="fill_parent"
android:layout_height="fill_parent"
android:orientation="vertical"
>
<FrameLayout
android:id="@android:id/tabcontent"
android:layout_width="fill_parent"
android:layout_height="fill_parent"
android:layout_weight="1"
></FrameLayout>
<TabWidget
android:id="@android:id/tabs"
android:layout_width="fill_parent"
android:layout_height="wrap_content"
android:visibility="gone"
></TabWidget>
<LinearLayout
android:layout_width="fill_parent"
android:layout_height="60dp"
android:orientation="horizontal"
android:gravity="center_vertical"
>
<ImageView
android:layout_width="wrap_content"
android:layout_height="wrap_content"
android:layout_weight="1"
android:src="@mipmap/tabhost_1"
/>
</LinearLayout>
</LinearLayout>
</TabHost>
2)代码
tabHost = getTabHost();
//需要继承TabActivity
//添加进tabHost
tabHost.addTab(tabHost.newTabSpec("11").setIndicator("选项卡1").setContent(new Intent(TabHostActy.this, MyQQActivity.class)));
tabHost.addTab(tabHost.newTabSpec("22").setIndicator("选项卡2").setContent(new Intent(TabHostActy.this, TabSpec2Acty.class)));
//设置ImageView监听事件
public void onClick(View view) {
imageView1.setImageResource(R.mipmap.tabhost_1);


switch (view.getId()) {
case R.id.tabhost_tv_tv1:
imageView1.setImageResource(R.mipmap.tabhost_1_);
tabHost.setCurrentTab(0);
break;
case R.id.tabhost_tv_tv2:
imageView2.setImageResource(R.mipmap.tabhost_2_);
tabHost.setCurrentTab(1);
break;
}


}

18.SlidingDrawer拖动框：（弃用）
<SlidingDrawer
android:layout_width="match_parent"
android:layout_height="400dp"
android:layout_alignParentBottom="true"
android:handle="@+id/acty_test_iv_ic"
android:content="@+id/acty_test_ll_ll"
>
<ImageView
android:id="@+id/acty_test_iv_ic"
android:layout_width="25dp"
android:layout_height="17dp"
android:src="@mipmap/a4z"
android:scaleType="fitXY"
/>
<LinearLayout
android:id="@+id/acty_test_ll_ll"
android:layout_width="match_parent"
android:layout_height="match_parent"
android:orientation="vertical"
android:background="#44000000">
</LinearLayout>
</SlidingDrawer>
```