package crm.poi;

import com.bjpowernode.crm.commons.utils.HSSFUtils;
import org.apache.poi.hssf.usermodel.*;
import java.io.FileInputStream;
import java.io.IOException;

//解析文件,把controller生成的文件中的内容解析打印出来
public class ParseExcelTest {
    public static void main(String[] args) throws IOException {
        FileInputStream file = new FileInputStream("F:\\1\\test\\fileupload\\activitys.xls");
        HSSFWorkbook wb = new HSSFWorkbook(file);
        HSSFSheet sheetAt = wb.getSheetAt(0);

        for (int i = 0;i<=sheetAt.getLastRowNum();i++){  //获取最后一行的下标,使用<=
            HSSFRow row = sheetAt.getRow(i);
            for (int j =0 ;j<row.getLastCellNum();j++){  //获取最后一列的下标+1,使用<
                HSSFCell cell = row.getCell(j);
                String value = HSSFUtils.getValue(cell);
                System.out.print(value+" ");
            }
            System.out.println();
        }


    }
}
