package product.idcard.android;
public class IDCardAPI {
	static {
		try {
			System.loadLibrary("IDCard");      // ✅ dependency first
			System.loadLibrary("AndroidIDCard");
		} catch (Throwable e) {
			e.printStackTrace();
		}
	}
	public IDCardAPI()
	{

	}

	/**
	 * 核心初始化
	 * '@param' lpUserID
	 * '@param' nType
	 * '@param' lpDirectory
	 * '@return'
	 */
	public native int   InitIDCard(String lpUserID, int nType,String lpDirectory);

	/**
	 * 释放核心
	 */
	public native void  FreeIDCard();

	/**
	 *设置证件类型
	 * '@param' nMainID
	 * '@param' nSubID
	 * '@return'
	 */
	public native int   SetIDCardID(int nMainID,int nSubID[]);

	/**
	 * 添加识别的证件类型
	 * '@param' nMainID
	 * '@param' nSubID
	 * '@return'
	 */
	public native int   AddIDCardID(int nMainID,int nSubID[]);

	public native int   GetGrabSignalType();
	public native int	DetectDocument();
	public native int   SetAcquireImageType(int nLightType,int nImageType);
	public native int   AcquireImage(int nImageSizeType);
	public native int   RecogIDCard();
	public native int   RecogIDCardEX(int nMainID ,int nSubID);
	public native int   LoadImageToMemory(String lpFileName,int nType);

	/**
	 * 获取识别结果
	 * '@param' nIndex
	 * '@return'
	 */
	public native String  GetRecogResult(int nIndex);
	public native String  GetRecogResultEx(int nAttr,int nIndex);

	/**
	 * 阿拉伯文数字转阿拉伯数字
	 * '@param' EasternArabic 阿拉伯文数字
	 * '@return'  阿拉伯数字
	 */
	public native String  ArabicToArabicNum(String EasternArabic);


	/**
	 *
	 * '@param' nIndex
	 * '@return'
	 */
	public native String  GetFieldName(int nIndex);
	public native String  GetFieldNameEx(int nAttr, int nIndex);
	public native String  GetVersionInfo();
	public native int   GetSubId();

	/**
	 * 保存图片
	 * '@param' lpFileName 存储的图片的路径
	 * '@return'
	 */
	public native int   SaveImage(String lpFileName);

	/**
	 * 保存证件的头像
	 * '@param' fileName  存储路径
	 * '@return'
	 */
	public native int   SaveHeadImage(String fileName);
	/**
	 * 设置语言的0中文，1英文
	 * '@param' nLangType  存储路径
	 * '@return'
	 */
	public native int SetLanguage(int nLangType);
	/**
	 * 证件的分类
	 * '@param' nCardType
	 * '@return'
	 */
	public native int   ClaasifyIDCard(int nCardType[]);

    public native int AutoProcessIDCard(int nCardType[]);

	public native String GetDocumentInfo(int[] mainID, int[] subID, int[] cardType);

    public native int SetConfigByFile(String filename);

	/**
	 *识别护照、通行证等芯片信息
	 * '@param' nDataGroup  读取DG信息
	 * '@param' nVIZ 是否识别 VIZ, 1代表识别VIZ，0代表不识别
	 * '@param' nSaveImageType 保存图片的类型 1代表存储的是白光图，2代表存储的是红外图，4代表存储的是紫外图，8代表存储的证件图，16代表存储的是证件头像，31存储全部以上全部图片
	 * '@return'
	 */
	public native int   RecogChipCard(int nDataGroup,int nVIZ,int nSaveImageType);

	/**
	 *识别机读码证件
	 * '@param' nVIZ
	 * '@param' nSaveImageType 1代表存储的是白光图，2代表存储的是红外图，4代表存储的是紫外图，8代表存储的证件图，16代表存储的是证件头像，31存储全部以上全部图片
	 * '@return'
	 */
	public native int   RecogGeneralMRZCard(int nVIZ,int nSaveImageType);

	/**
	 *识别除机读码证件、护照、通行证等芯片信息的其他证件
	 * '@param' nSaveImageType 1代表存储的是白光图，2代表存储的是红外图，4代表存储的是紫外图，8代表存储的证件图，16代表存储的是证件头像，31存储全部以上全部图片
	 * '@return'
	 */
	public native int   RecogCommonCard(int nSaveImageType);

	/**
	 * 保存图片
	 * '@param' lpPath 存储图片的路径
	 * '@param' nType 类型 1代表存储的是白光图，2代表存储的是红外图，4代表存储的是紫外图，8代表存储的证件图，16代表存储的是证件头像，31存储全部以上全部图片
	 * '@return'
	 */
	public native int   SaveImageEx(String lpPath,int nType);
	/**
	 * 设置IO状态
	 * '@return'
	 */
	public native int   SetIOStatus(int nIOType,int bOpen);
	/**
	 * 获取当前设备是否支持二代证读卡
	 * '@return'
	 */
	public native int   GetSupportSID();
	/**
	 * 获取当前识别证件名称
	 * '@return'
	 */
	public native String   GetIDCardName();


	/**************新添加的接口**************/
	//获取当前设备名
	public native String GetCurrentDevice();

	//检测设备是否在线
	public native int CheckDeviceOnline();

	//检测设备是否在线(只要有设备都可以)
	public native int CheckDeviceOnlineEx();

	//获取设备序列号
	public native  String GetDeviceSN();

	//获取设备类型
	public native  int GetDeviceType();

	//核实设备的SI  ReadDeviceSI未导出，即客户只可以WriteDeviceSI和CheckDeviceSI
	public native int CheckDeviceSI(String strlpSI,int nBuffLen);

	public native int WriteDeviceSI(String strlpSI,int nBuffLen);
	
	//识别条码
	public native String RecogBarCode();
	//使用指定图像类型识别条码(1:白光图，2:红外图)，返回条码个数
	public native int RecogBarCodeNum(int nImageType);
	//获取条码识别结果
	public native String GetBarcodeRecogResult(int nIndex);
	//获取识别到的条码个数
	public native int GetBarcodeCount();
	//设置蜂鸣器
	public native int BuzzerAlarm(int nDuration);

	//**********************************吸入式接口**********************************

	public native int InitIDCardSL(String lpUserID, int nType, String lpDirectory, int nInitType);

	public native int FreeIDCardSL();

	//加载内存图像
	public native int LoadImageDataSL(boolean[] pBuffer, int nWidth, int nHeight, int nBitCount, int nLineLength, int nResolution, int nImageType);

	//对内存图像进行识别
	public native int RecogIDCardSL(int nReject);

	//获取识别结果
	public native String GetRecogResultSL(int nType, int nIndex);

	//获取字段名
	public native String GetFieldNameSL(int nType, int nIndex);

	/*
	* 获取头像内存数据
	* @param nType
	* @param pBuffer
	* @param nBufferLen
	* @param nParam
	* nParam[0]:nWidth
	* nParam[1]:nHeight
	* nParam[2]:nBitCount
	* nParam[3]:nLineLength
	* */
	public native int GetHeadImageDataSL(int nType, boolean[] pBuffer, int nBufferLen, int[] nParam);

	//当前证件信息，MainID SubID
	public native int GetCardInfoSL(int nType, int[] nMainID, int[] nSubID);

	//获取图像旋转方向  -1 不支持 ， 0 不需要选择，2 旋转180度
	public native int GetImageDirectionSL();

	//0无 1 正面在上 2背面在上
	public native int GetCardDirectionSL();

	//设置是否要读卡
	public native int SetRecogChipCardAttributeSL(int nReadCard);

}

















