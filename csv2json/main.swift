//
//  main.swift
//  csv2json
//
//  Created by takahiro on 2024/07/27.
//
/*
 todo
 1. CR,LF code
 2. encoding
 3. fields
 */
import Foundation

//print("Hello, World!")

let argv = ProcessInfo.processInfo.arguments
//print(argv[1], argv[2])
if argv.count < 3 {
    print("csv2json <file_path> <dest_keys> # dest_keys ex.: \"1, 2,4\"")
    exit(1)
}

class csv2json {
    private(set) var csvpath:String = ""
    private(set) var fields = [Int]()
    private(set) var headers = [String]()
    private(set) var records = [[String]]()
    private(set) var buf:String = ""
    private(set) var json_buf:String = ""

    init(csvpath:String) {
        self.csvpath = csvpath
    }
    
    init(csvpath:String, fields:String) {
        self.csvpath = csvpath
        let f_set = fields.components(separatedBy: ",")
        var i = 0
        while(i<f_set.count) {
            self.fields.append(Int(f_set[i].trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines))!)
            i += 1
        }
    }
    
    func printHeaders() {
        print(headers)
    }
    
    func dumpRecords() {
        print(records)
    }
    
/*    func getNetFile(uri:String, savepath:String) {
        let url = URL(string: uri)
        let req = URLRequest(url: url!)
        let task = URLSession.shared.dataTask(with: req, completionHandler: {
            (data, res, err) in
            if data != nil {
                self.buf = data //String(data: data!, encoding: String.Encoding.utf8)
            }
        })
    }
*/
    func loadcsv() {
        do {
            if csvpath.range(of: "http") != nil {
                self.buf = try String(contentsOf: URL(string: self.csvpath)!, encoding: String.Encoding.utf8)
            } else {
                self.buf = try String(contentsOfFile: self.csvpath, encoding: String.Encoding.utf8)
            }
            let arr = buf
                .trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
                .components(separatedBy: NSCharacterSet.newlines)
            self.headers = arr[0].components(separatedBy: ",")

            var i = 1
            while(i<arr.count) {
                self.records.append(arr[i].components(separatedBy: ","))
                i += 1
            }
        } catch {
            print(error)
        }
    }
    
    func writeRecord(var i:Int, var j:Int) {
    //  print(records[i][j])
        /* remove "'" */
        var str = String(records[i][j]).trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        if str.first=="'" {
            str.removeFirst()
            str.removeLast()
            records[i][j] = str
        }

        /* key */
        if headers[j].first=="\"" {
            json_buf += "\t" + headers[j] + ": "
        } else {
            json_buf += "\t\"" + headers[j] + "\"" + ": "
        }

        /* value */
        if records[i][j]=="  " {
            json_buf += "\"\"" + ",\n"
        } else {
            if Int(records[i][j]) != nil {
                /* 文字数列 */
                if str.first=="0" && 1 < str.count {
                    json_buf += "\"" + records[i][j] + "\",\n"
                } else {
                    /* Integer, Numeric */
                    json_buf += records[i][j] + ",\n"
                }
            } else {
                /* 文字列 */
                if records[i][j].first=="\"" {
                    json_buf += records[i][j] + ",\n"
                } else {
                    json_buf += "\"" + records[i][j] + "\",\n"
                }
            }
        }
    }
    
    func writeRecords() {
//        print(records.count)
        var i = 0
        if fields.count != 0 {
            while(i<records.count) {
                json_buf += "{\n"
                var j = 0
                while(j<records[i].count) {
                    var k = 0
                    while(k<fields.count) {
                        if j == fields[k] {
                            writeRecord(var: i, var: j)
                        }
                        k += 1
                    }
                    j += 1
                }
                json_buf += "},\n"
                i += 1
            }
        } else {
            while(i<records.count) {
                json_buf += "{\n"
                var j = 0
                while(j<records[i].count) {
                    writeRecord(var: i, var: j)
                    j += 1
                }
                json_buf += "},\n"
                i += 1
            }
        }
        
        do {
            try json_buf.write(toFile: "/Users/takahiro/Downloads/project/csv2json/csv2json/dest.json", atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print(error)
        }
    }

}

var cj = csv2json(csvpath: argv[1], fields: argv[2])
cj.loadcsv()
cj.printHeaders()
//cj.printRecords()
cj.writeRecords()
