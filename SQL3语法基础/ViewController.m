//
//  ViewController.m
//  SQL3语法基础
//
//  Created by 彦鹏 on 15/11/24.
//  Copyright © 2015年 Huyp. All rights reserved.
//

#import "ViewController.h"
#import <sqlite3.h>

@interface ViewController ()

@property (assign,nonatomic)sqlite3 * database;

@end

@implementation ViewController

@synthesize database;

- (void)viewDidLoad {
    [super viewDidLoad];
    //创建数据库路径 SQL只识别C语法,所以必须转成char *
    const char * sqlPath = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"test.sqlite"] UTF8String];
    NSLog(@"数据库路径:%s",sqlPath);
    
    //结果
    int result = sqlite3_open(sqlPath, &database);
    if (result == SQLITE_OK) {
        NSLog(@"打开/创建数据库成功");
        char * err = NULL;
        //创建表格语句
        const char * sql = "create table if not exists t_student (id integer primary key autoincrement, name text, age integer)";
        //创建表
        result = sqlite3_exec(database, sql, NULL, NULL, &err);
        if (result == SQLITE_OK) {
            NSLog(@"创建表成功");
        }
        else {
            NSLog(@"创建表失败,原因:%s",err);
        }
    }
    else {
        NSLog(@"打开/创建数据库失败");
    }
}


- (IBAction)insert:(id)sender {
    //把文本框转换成C语言
    const char * name = [_text1.text UTF8String];//名字
    const char * age = [_text2.text UTF8String];//年龄
    //增加一行语句
    char * sql = "insert into t_student (name, age) values (?,?)";
    /**
     sqlite 操作二进制数据需要用一个辅助的数据类型：sqlite3_stmt * 。
     这个数据类型 记录了一个“sql语句”。为什么我把 “sql语句” 用双引号引起来？因为你可以把 sqlite3_stmt * 所表示的内容看成是 sql语句，但是实际上它不是我们所熟知的sql语句。它是一个已经把sql语句解析了的、用sqlite自己标记记录的内部数据结构。
     */
    sqlite3_stmt * stmt;
    
    //这里要执行sqlite语句了 (数据库,SQL语句,-1,&stmt,NULL); 增删改查都是用这一句代码
    //不同的地方就是sql语句的不同,sqlite3_bind_text()中的值不同而已.
    int result = sqlite3_prepare_v2(database, sql, -1, &stmt, NULL);
    if (result == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, name, -1, NULL);
        sqlite3_bind_text(stmt, 2, age, -1, NULL);
    }
    else {
        NSLog(@"准备失败");
    }
    //检验是否操作完成
    if (sqlite3_step(stmt) == SQLITE_DONE) {
        NSLog(@"操作完成");
    }
    else {
        NSLog(@"操作失败");
    }
    //每次调用sqlite3_prepare 函数sqlite 会重新开辟sqlite3_stmt空间，
    //所以在使用同一个sqlite3_stmt 指针再次调用sqlite3_prepare 前
    //需要调用sqlite3_finalize先释放空间
    sqlite3_finalize(stmt);
}

- (IBAction)drop:(id)sender {
    char * err = NULL;
    char * sql = "drop table if exists t_student";
    int result = sqlite3_exec(database, sql , NULL, NULL, &err);
    NSLog(@"%d",result);
    if (result == SQLITE_OK) {
        NSLog(@"删除表成功");
    }
    else {
        NSLog(@"%s",err);
    }
}

- (IBAction)update:(id)sender {
    const char * ID = [_text1.text UTF8String];
    const char * newname = [_text2.text UTF8String];
    sqlite3_stmt * stmt;
    char * sql = "update t_student set name = ? where id = ?";
    int result = sqlite3_prepare_v2(database, sql , -1, &stmt, NULL);
    if (result == SQLITE_OK) {
        result = sqlite3_bind_text(stmt, 1, newname, -1, NULL);
        result = sqlite3_bind_text(stmt, 2, ID, -1, NULL);
        if (result != SQLITE_OK) {
            NSLog(@"更新数据有问题");
        }
        if (sqlite3_step(stmt) != SQLITE_DONE) {
            NSLog(@"更新数据不成功");
        }
    }
    else {
        NSLog(@"修改数据失败");
    }
    sqlite3_finalize(stmt);
}

- (IBAction)select:(id)sender {
    char * sql = "select id , name , age from t_student";
    sqlite3_stmt * stmt;
    int result = sqlite3_prepare_v2(database, sql , -1, &stmt, NULL);
    if (result == SQLITE_OK) {
        //sqlite3_step(stmt) == SQLITE_ROW 查询时使用
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            int ID = sqlite3_column_int(stmt, 0);
            char * name = (char *)sqlite3_column_text(stmt, 1);
            NSString * strName = [NSString stringWithUTF8String:name];
            int age = sqlite3_column_int(stmt, 2);
            NSLog(@"%d,%@,%d",ID,strName,age);
        }
    }
    sqlite3_finalize(stmt);
}

- (IBAction)selectWhere:(id)sender {
    const char * name = [_text1.text UTF8String];
    const char * age = [_text2.text UTF8String];
    
    //* 代表查询这条所有信息
    const char * sql = "select * from t_student where name is ? and age > ?";
    sqlite3_stmt * stmt;
    int result = sqlite3_prepare_v2(database, sql , -1, &stmt, NULL);
    if (result == SQLITE_OK) {
        if (sqlite3_bind_text(stmt, 1, name, -1, NULL) == SQLITE_OK && sqlite3_bind_text(stmt, 2, age, -1, NULL) == SQLITE_OK) {
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                int ID = sqlite3_column_int(stmt, 0);
                char * name = (char *)sqlite3_column_text(stmt, 1);
                NSString * strName = [NSString stringWithUTF8String:name];
                int age = sqlite3_column_int(stmt, 2);
                NSLog(@"%d,%@,%d",ID,strName,age);
//                NSLog(@"%d",age);
            }
        }
    }
    sqlite3_finalize(stmt);
}

- (IBAction)del:(id)sender {
    //
    int a = [_text1.text intValue];
    sqlite3_stmt * stmt;
    char * sql = "delete from t_student where id = ?";
    int result = sqlite3_prepare_v2(database, sql , -1, &stmt, NULL);
    if (result == SQLITE_OK) {
        result = sqlite3_bind_int(stmt, 1, a);
        if (result == SQLITE_OK) {
            result = sqlite3_step(stmt);
            if (result == SQLITE_DONE) {
                NSLog(@"删除成功");
            }
            else {
                NSLog(@"删除失败");
            }
        }
    }
    else {
        NSLog(@"删除失败");
    }
    
    sqlite3_finalize(stmt);
}

@end
