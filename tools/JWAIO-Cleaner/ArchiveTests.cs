using System;
using System.IO;
using System.Linq;
using JwaioCleaner;
class ArchiveTests {
 static void Main(string[] args){int n=0;foreach(string r in Directory.GetDirectories(args[0])) {
  var p=Engine.Scan(r,true,true);if(p.Files.Count==0)throw new Exception("No widget: "+r);
  var keep=p.Files.Where(f=>f.Save).Select(f=>new {f.Relative,f.Hash}).ToList();
  var result=Engine.Execute(p);if(Engine.Scan(r,true,true).Files.Count!=0)throw new Exception("Remaining targets");
  string backup=Directory.GetDirectories(Path.Combine(r,"JWAIO-Sauvegardes")).Single();
  foreach(var f in keep)if(Engine.Hash(Path.Combine(backup,f.Relative))!=f.Hash)throw new Exception("Backup mismatch");
  Console.WriteLine("PASS "+Path.GetFileName(r)+": "+p.Files.Count+" files removed, "+keep.Count+" assets saved and verified");n++;
 }Console.WriteLine("PASS "+n+" official archive copies");}
}
