using System;
using System.IO;
using System.Linq;
using System.Collections.Generic;
using JwaioCleaner;
class Tests {
 static int passed;
 static void Assert(bool v,string text){if(!v)throw new Exception(text);passed++;Console.WriteLine("PASS "+text);}
 static void Put(string root,string path,string content){string f=Path.Combine(root,path);Directory.CreateDirectory(Path.GetDirectoryName(f));File.WriteAllText(f,content);}
 static string Fixture(string parent,string name){string r=Path.Combine(parent,name);Directory.CreateDirectory(r);
  Put(r,"WIDGETS/JWAIO/main.lua","local BASE = '/WIDGETS/JWAIO/'");Put(r,"WIDGETS/JWAIO/config.lua","custom config");Put(r,"WIDGETS/JWAIO/skins/custom/skin.lua","my skin");Put(r,"WIDGETS/JWAIO/skins/custom/background.png","personal photo");Put(r,"SOUNDS/fr/JWAIO/arm.wav","audio");Put(r,"SOUNDS/en/JWAIO/arm.wav","audio en");Put(r,"LOGS/JWAIO/F001.csv","private flight");
  Put(r,"WIDGETS/SIXTY9/main.lua","local BASE = '/WIDGETS/SIXTY9/'");Put(r,"WIDGETS/SIXTY9/img/logo.png","legacy logo");Put(r,"WIDGETS/SIXTY9/config.lua","legacy customization");Put(r,"SOUNDS/fr/SIXTY9/arm.wav","old audio");Put(r,"LOGS/SIXTY9/F001.csv","old flight");
  Put(r,"SCRIPTS/TOOLS/jwbox.lua","-- toolName = 'JWAIO Boxer'");Put(r,"SCRIPTS/JWBOX/core.lua","boxer core");Put(r,"SCRIPTS/JWBOX/ui.lua","boxer ui");Put(r,"SCRIPTS/JWBOX/CFG/settings.lua","boxer personal settings");Put(r,"SOUNDS/fr/JWBOX/arm.wav","boxer audio");Put(r,"SOUNDS/en/JWBOX/arm.wav","boxer audio en");Put(r,"LOGS/JWBOX/F001.csv","boxer private flight");
  Put(r,"SCRIPTS/TOOLS/other.lua","other tool");Put(r,"SCRIPTS/OTHER/core.lua","other script");
  Put(r,"WIDGETS/OTHER/main.lua","other widget");Put(r,"SOUNDS/fr/arm.wav","shared audio");Put(r,"LOGS/Model001.csv","edgetx flight");Put(r,"MODELS/model01.yml","model untouched");Put(r,"WIDGETS/JWAIO-unrelated/main.lua","unrelated content");return r;
 }
 static void Main(string[] args){
  string parent=Path.GetFullPath(args[0]);Directory.CreateDirectory(parent);
  foreach(bool skins in new[]{true,false})foreach(bool logs in new[]{true,false})foreach(bool boxerSettings in new[]{true,false}){
   string r=Fixture(parent,"options-"+skins+"-"+logs+"-"+boxerSettings);var plan=Engine.Scan(r,skins,logs,boxerSettings);Assert(plan.Products.Contains("JWAIO BOXER")&&plan.Products.Contains("JWAIO TX15 / TX16")&&plan.Products.Contains("SIXTY9"),"detected products identified explicitly");string result=Engine.Execute(plan);
   Assert(!Directory.Exists(Path.Combine(r,"WIDGETS/JWAIO")),"widget removed "+skins+"/"+logs);
   Assert(!Directory.Exists(Path.Combine(r,"WIDGETS/SIXTY9")),"SIXTY9 removed");
   Assert(File.Exists(Path.Combine(r,"LOGS/JWAIO/F001.csv"))==logs,"JWAIO logs option");Assert(File.Exists(Path.Combine(r,"LOGS/SIXTY9/F001.csv"))==logs,"SIXTY9 logs option");
   Assert(!Directory.Exists(Path.Combine(r,"SCRIPTS/JWBOX")),"Boxer modules removed");Assert(!File.Exists(Path.Combine(r,"SCRIPTS/TOOLS/jwbox.lua")),"Boxer launcher removed");Assert(!Directory.Exists(Path.Combine(r,"SOUNDS/fr/JWBOX"))&&!Directory.Exists(Path.Combine(r,"SOUNDS/en/JWBOX")),"Boxer sounds removed");Assert(File.Exists(Path.Combine(r,"LOGS/JWBOX/F001.csv"))==logs,"Boxer logs option");
   Assert(File.ReadAllText(Path.Combine(r,"WIDGETS/OTHER/main.lua"))=="other widget"&&File.ReadAllText(Path.Combine(r,"SOUNDS/fr/arm.wav"))=="shared audio"&&File.ReadAllText(Path.Combine(r,"LOGS/Model001.csv"))=="edgetx flight"&&File.ReadAllText(Path.Combine(r,"MODELS/model01.yml"))=="model untouched","other data unchanged");
   Assert(File.ReadAllText(Path.Combine(r,"SCRIPTS/TOOLS/other.lua"))=="other tool"&&File.ReadAllText(Path.Combine(r,"SCRIPTS/OTHER/core.lua"))=="other script","other EdgeTX scripts unchanged");
   Assert(File.Exists(Path.Combine(r,"WIDGETS/JWAIO-unrelated/main.lua")),"lookalike name retained");
   Assert(!Directory.Exists(Path.Combine(r,"SOUNDS/en/JWAIO")),"other sound languages removed");
   if(skins||boxerSettings){var saved=Directory.GetFiles(Path.Combine(r,"JWAIO-Sauvegardes"),"*",SearchOption.AllDirectories);Assert(saved.Length==(skins?4:0)+(boxerSettings?1:0),"selected skins and Boxer settings saved");if(skins)Assert(saved.Any(f=>File.ReadAllText(f)=="personal photo")&&saved.Any(f=>File.ReadAllText(f)=="legacy customization"),"skin backup contents verified");if(boxerSettings)Assert(saved.Any(f=>File.ReadAllText(f)=="boxer personal settings"),"Boxer CFG backup verified");}
   else Assert(!Directory.Exists(Path.Combine(r,"JWAIO-Sauvegardes")),"no unwanted backup");
   Assert(Engine.Scan(r,skins,logs,boxerSettings).Files.Count==0,"second run empty and backups excluded");
  }
  string changed=Fixture(parent,"changed");var stale=Engine.Scan(changed,true,true,true);Put(changed,"WIDGETS/JWAIO/main.lua","changed");bool rejected=false;try{Engine.Execute(stale);}catch(IOException){rejected=true;}Assert(rejected&&File.Exists(Path.Combine(changed,"SOUNDS/fr/JWAIO/arm.wav")),"changed file rejects entire plan");
  string added=Fixture(parent,"added");stale=Engine.Scan(added,true,true,true);Put(added,"WIDGETS/JWAIO/new.lua","new");rejected=false;try{Engine.Execute(stale);}catch(IOException){rejected=true;}Assert(rejected&&File.Exists(Path.Combine(added,"WIDGETS/JWAIO/main.lua")),"added file rejects entire plan");
  string ro=Fixture(parent,"readonly");var rf=Path.Combine(ro,"WIDGETS/JWAIO/config.lua");File.SetAttributes(rf,FileAttributes.ReadOnly);stale=Engine.Scan(ro,true,true,true);rejected=false;try{Engine.Execute(stale);}catch(IOException e){rejected=e.Message.Contains("interrompu");}Assert(rejected,"read-only failure reported");File.SetAttributes(rf,FileAttributes.Normal);
  string nested=Fixture(parent,"nested");Put(nested,"JWAIO-old-copy/WIDGETS/JWAIO/main.lua","local BASE = '/WIDGETS/JWAIO/'");Put(nested,"WIDGETS/JWAIO-old/main.lua","local BASE = '/WIDGETS/JWAIO/'");Put(nested,"JWAIO_BOXER_old/SCRIPTS/TOOLS/jwbox.lua","old boxer launcher");Put(nested,"JWAIO_BOXER_old/SCRIPTS/JWBOX/core.lua","old boxer core");var np=Engine.Scan(nested,true,true,true);Assert(np.Found.Any(x=>x.Contains("JWAIO-old-copy"))&&np.Found.Any(x=>x.Contains("JWAIO-old"))&&np.Found.Any(x=>x.Contains("JWAIO_BOXER_old")),"nested archives and renamed old widget detected");Engine.Execute(np);Assert(!File.Exists(Path.Combine(nested,"WIDGETS/JWAIO-old/main.lua"))&&!Directory.Exists(Path.Combine(nested,"JWAIO_BOXER_old","SCRIPTS","JWBOX")),"renamed old widget and Boxer package removed");
  bool outside=false;try{Engine.Safe(nested,parent);}catch(IOException){outside=true;}Assert(outside,"path outside selected root rejected");
  if(args.Length>1){bool link=false;try{Engine.Scan(args[1],true,true,true);}catch(IOException){link=true;}Assert(link,"junction rejected before any deletion");}
  Console.WriteLine("TOTAL "+passed+" assertions passed");
 }
}
