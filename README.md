# MT4-ADX
EA ที่ทำขึ้นมาสำหรับเทรดบิทคอยน์บนแพลตฟอร์ม MT4 [Exness](https://one.exness-track.com/a/sjnruprd) โดยสามารถใช้ได้กับทุกประเภทบัญชี

*โดยไม่ได้จำกัดเฉพาะบิทคอยน์ สามารถใช้ได้กับคู่เงิน ทอง หรืออื่นๆ โปรด backtest และทดสอบด้วยตัวเอง*

![image](https://user-images.githubusercontent.com/96503948/199771070-bdeef7ea-50eb-4dad-8201-9efc895733bf.png)

## การทำงาน
- จะใช้สัญญาณจาก ADX indicator ในการเปิดออเดอร์ทั้ง BUY และ SELL
- Take Profit โดยกำหนดระยะ และมีฟังก์ชั่น trailing เพื่อการ take profit ให้มีคุณภาพมากขึ้น(ในกรณีที่กราฟเคลื่อนที่ถูกทางแล้วกระชากต่ออย่างกระทันหัน จะได้กำไรมากขึ้น)
- ถ้ากราฟสวนทางจะใช้วิธีการเปิดออเดอร์เพิ่มเพื่อสะสมและสามารถเพิ่มขนาด lot ของออเดอร์ที่เปิดสะสมได้ โดยจังหวะการเปิดออเดอร์สะสมจะใช้ RSI indicator ในการเข้ามาตัดสินใจ( ราคาจะต้องสวนทางมากกว่าระยะที่ตั้งค่าไว้ และRSI จะต้องต่ำกว่า 30 )
- สามารถกำหนด Stop Loss ได้ ในกรณีที่กราฟสวนทางมากๆ
- มีระบบหลบข่าวในกรณีที่ต้องเปิดออเดอร์แรก

## รายละเอียดการตั้งค่า
![image](https://user-images.githubusercontent.com/96503948/199774569-a431993c-dd22-499f-bcf4-7b73d726c27d.png)
- OrderSize คือ ขนาดของ lot สำหรับออเดอร์แรก
- AllowBUY คือ อนุญาตให้ BUY
- AllowSELL คือ อนุญาตให้ SELL
- SpreadLimit คือ ค่า spread สูงสุดที่อนุญาต
- Slippage คือ ค่า slippage สูงสุดที่อนุญาต
- TP_GAP คือ ระยะที่จะ take profit
- Trailing คือ ระยะที่จะ trailing (ในกรณีที่ไม่ต้องการใช้ trailing ให้ใส่เป็น 0)
- DCA_Multiply_Lot คือ ขนาด lot ของออเดอร์ที่จะซื้อสะสม โดยจะนำขนาด lot ของออเดอร์ล่าสุดมาคูณกับค่านี้ เช่น ออเดอร์ที่แล้ว 1.0 lot ถ้าใส่ค่าเป็น 2 ในออเดอร์ถัดไปจะเปิดเป็น 2.0 lot
- DCA_GAP คือ ระยะที่จะเริ่มหาจังหวะเปิดออเดอร์สะสม
- DCA_Profit_money คือ เมื่อมีการเปิดออเดอร์สะสม ถ้ายอด Profit ถึงค่านี้จะทำการปิดออเดอร์ทั้งหมดพร้อมกันทันที โดยค่านี้จะเป็นหน่วย base currency และไม่ต้องกังวลว่าจะโดนหักค่า commission หรือ swap เพราะค่าตรงนี้คือ real profit ที่ถูกหักออกจากทั้งค่า commission และ swap เรียบร้อยแล้ว
- NewsFilter คือ เปิดใช้งานการเทรดเลี่ยงช่วงที่มีข่าว
- NewsGreen คือ เลี่ยงข่าวเขียว
- NewsYellow คือ เลี่ยงข่าวเหลือง
- NewsRed คือ เลี่ยงข่าวแดง
- NewsSymbol คือ สกุลเงินมาตรฐานที่ต้องการใช้อ้างอิงเพื่อเลี่ยงข่าว (สามารถใส่ได้หลายสกุล)
- PleaseAddThisURLtoMT4Setting คือ URL ที่จะไปดึงเอาข่าวมาวิเคราะห์ โดยให้นำ URL นี้ไปเพิ่มในรายการ URL ที่ MT4 อนุญาต
- MagicNumber คือ เลขอัตลักษณ์ของ EA

## ฟังก์ชั่นเทรดหลบข่าว
ขอบคุณ source code จากคุณ Yurij Izyumov [https://www.mql5.com/en/code/19138](https://www.mql5.com/en/code/19138)

![image](https://user-images.githubusercontent.com/96503948/199779141-7f0c362a-c829-44a6-9cf5-9c25a586f87d.png)

นำ URL ที่ได้จาก parameter "PleaseAddThisURLtoMT4Setting" ของ EA มาเพิ่มในการตั้งค่าการอนุญาตของ MT4 เพื่อให้ EA สามารถเชื่อมต่อไปดึงข้อมูลข่าวมาวิเคราะห์ได้ โดย timezone ของข่าวจะถูกคำนวณอัตโนมัติโดย EA เพื่อให้ระบบเทรดหลบข่าวทำงานได้ถูกต้องตาม timezone ของโบรกเกอร์นั้นๆ

ฟังก์ชั่นหลบข่าวจะมีเส้นบอกว่าตอนไหนมีข่าว โดย EA จะไม่ทำการเปิดออเดอร์แรกภายในทั้งก่อนหน้าและหลังเวลาข่าว 5 นาที แต่ถ้าหากเป็นออเดอร์สะสมจะยังเปิดตามปกติ
![image](https://user-images.githubusercontent.com/96503948/199784621-188ac7ba-7d78-4d95-9f0f-43051ef22193.png)

## ข้อแนะนำ
- เงินทุนแนะนำคือ 1,000USD ถ้าทุนน้อยให้ใช้บัญชี Standard Cent (โปรดทำการ backtest และตัดสินใจด้วยตัวเอง)
- หากต้องการหยุดรัน EA ในกรณีที่มีออเดอร์ค้างอยู่ ให้ตั้งค่า AllowBUY และ AllowSELL เป็น false  ตัว EA จะหยุดเปิดออเดอร์แรก(แต่ออเดอร์สะสมจะยังคงเปิดเรื่อยๆจนกว่าจะหาจังหวะปิดทุกออเดอร์ได้)
- โปรดทดลองกับ backtest เพื่อทดสอบระยะ การตั้งค่า และการทำงานของ EA ว่าถูกต้องหรือไม่
- EA นี้ถูกออกแบบมาให้สะสมและเพิ่มขนาดออเดอร์เพื่อแก้ทางกราฟสวนทาง โปรดคำนวณระยะและเงินทุนให้ดี เพราะถ้าหากไม่ได้วางแผนตรงนี้อาจเกิดการล้างพอร์ตได้

### "ผู้พัฒนาแค่ต้องการแบ่งปันสิ่งที่ตัวเองทำอยู่เท่านั้น ไม่ได้จะชักชวนให้มาลงทุนหรือมีส่วนได้ส่วนเสียกับผู้นำไปใช้แต่อย่างใด การเอา EA นี้ไปใช้งานถือว่าผู้นำไปใช้ได้ยอมรับความเสี่ยงตรงนี้และได้ตัดสินใจด้วยตัวเอง หากเกิดการขาดทุน ถือว่าไม่เกี่ยวข้องกับผู้พัฒนาทุกกรณี"

## Donate
BUSD ผ่าน BSC(BEP20) ได้ที่ `0x1c61e16b2245608c0d40862bc61ec461f3e2461b` หรือสมัครบัญชี Exness ผ่าน link นี้ : [https://one.exness-track.com/a/sjnruprd](https://one.exness-track.com/a/sjnruprd)
