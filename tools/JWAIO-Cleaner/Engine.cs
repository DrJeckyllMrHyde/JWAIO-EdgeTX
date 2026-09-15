using System;
using System.IO;
using System.Linq;
using System.Collections.Generic;
using System.Security.Cryptography;
using System.Text.RegularExpressions;

namespace JwaioCleaner {
public sealed class Entry {
 public string Path, Relative, Hash; public long Size; public bool Save;
}
public sealed class Plan {
 public string Root; public bool Skins, Logs;
 public List<Entry> Files = new List<Entry>();
 public List<string> Dirs = new List<string>();
 public List<string> Found = new List<string>();
 public List<string> Kept = new List<string>();
 public long Bytes { get { return Files.Sum(f=>f.Size); } }
}
public static class Engine {
 static StringComparison Comparison = StringComparison.OrdinalIgnoreCase;
 public static string Full(string p) { return System.IO.Path.GetFullPath(p).TrimEnd(System.IO.Path.DirectorySeparatorChar)+System.IO.Path.DirectorySeparatorChar; }
 public static void Safe(string root, string path) {
  root=Full(root); string full=System.IO.Path.GetFullPath(path);
  if (!Full(full).StartsWith(root,Comparison)) throw new IOException("Chemin hors du volume sélectionné : "+path);
  string current=full;
  while(!String.IsNullOrEmpty(current)) {
   if ((File.GetAttributes(current)&FileAttributes.ReparsePoint)!=0) throw new IOException("Lien ou jonction refusé : "+current);
   var parent=Directory.GetParent(current); if(parent==null) break; current=parent.FullName;
  }
 }
 public static string Hash(string p) { using(var s=File.Open(p,FileMode.Open,FileAccess.Read,FileShare.Read)) using(var h=SHA256.Create()) return Convert.ToBase64String(h.ComputeHash(s)); }
 static bool Family(string n) { return Regex.IsMatch(n,@"^(JWAIO|SIXTY9)([-_. ].+)?$",RegexOptions.IgnoreCase); }
 static bool Exact(string n) { return n.Equals("JWAIO",Comparison)||n.Equals("SIXTY9",Comparison); }
 static bool Signature(string p) {
  var main=System.IO.Path.Combine(p,"main.lua"); if(!File.Exists(main)) return false;
  Safe(p,main); using(var r=new StreamReader(main)) { char[] buf=new char[8192]; int n=r.Read(buf,0,buf.Length); string s=new string(buf,0,n); return s.Contains("/WIDGETS/JWAIO/")||s.Contains("/WIDGETS/SIXTY9/"); }
 }
 static void Walk(Plan p,string dir,bool save,bool widget,bool legacy,int depth) {
  if(depth>32) throw new IOException("Arborescence trop profonde."); Safe(p.Root,dir); p.Dirs.Add(dir);
  foreach(string f in Directory.GetFiles(dir)) { Safe(p.Root,f); var info=new FileInfo(f);
   if(p.Files.Count>=100000) throw new IOException("Trop de fichiers : analyse interrompue.");
   bool keep=save||(widget&&legacy&&p.Skins&&System.IO.Path.GetFileName(f).Equals("config.lua",Comparison));
   p.Files.Add(new Entry {Path=f,Relative=f.Substring(p.Root.Length),Size=info.Length,Hash=Hash(f),Save=keep});
  }
  foreach(string d in Directory.GetDirectories(dir)) {
   string name=System.IO.Path.GetFileName(d); bool keep=save||(widget&&p.Skins&&(name.Equals("skins",Comparison)||(legacy&&name.Equals("img",Comparison))));
   Walk(p,d,keep,false,false,depth+1);
  }
 }
 static void Target(Plan p,string dir,bool widget) {
  Safe(p.Root,dir); bool legacy=widget&&!Directory.Exists(System.IO.Path.Combine(dir,"skins"));
  p.Found.Add(dir.Substring(p.Root.Length)); Walk(p,dir,false,widget,legacy,0);
 }
 static void ScanBase(Plan p,string b) {
  string w=System.IO.Path.Combine(b,"WIDGETS");
  if(Directory.Exists(w)) { Safe(p.Root,w); foreach(string d in Directory.GetDirectories(w)) {
   string n=System.IO.Path.GetFileName(d); if(Family(n)&&(Exact(n)||Signature(d))) Target(p,d,true);
  }}
  string sounds=System.IO.Path.Combine(b,"SOUNDS");
  if(Directory.Exists(sounds)) { Safe(p.Root,sounds); foreach(string lang in Directory.GetDirectories(sounds)) {
   Safe(p.Root,lang); foreach(string name in new[]{"JWAIO","SIXTY9"}) { string d=System.IO.Path.Combine(lang,name); if(Directory.Exists(d)) Target(p,d,false); }
  }}
  foreach(string name in new[]{"JWAIO","SIXTY9"}) {
   string d=System.IO.Path.Combine(b,"LOGS",name); if(Directory.Exists(d)) {Safe(p.Root,d); if(p.Logs) p.Kept.Add(d.Substring(p.Root.Length)); else Target(p,d,false);}
   string f=System.IO.Path.Combine(b,name+"_README.txt"); if(File.Exists(f)) {Safe(p.Root,f); p.Files.Add(new Entry{Path=f,Relative=f.Substring(p.Root.Length),Size=new FileInfo(f).Length,Hash=Hash(f)});}
  }
 }
 public static Plan Scan(string root,bool skins,bool logs) {
  var p=new Plan{Root=Full(root),Skins=skins,Logs=logs}; Safe(p.Root,p.Root);
  if(!Directory.Exists(System.IO.Path.Combine(p.Root,"WIDGETS")) && !Directory.Exists(System.IO.Path.Combine(p.Root,"RADIO")) && !Directory.Exists(System.IO.Path.Combine(p.Root,"SOUNDS"))) throw new IOException("Ce dossier ne ressemble pas à la racine du stockage EdgeTX. Sélectionnez le volume qui contient WIDGETS ou RADIO.");
  ScanBase(p,p.Root);
  foreach(string d in Directory.GetDirectories(p.Root)) { if(Family(System.IO.Path.GetFileName(d))&&!System.IO.Path.GetFileName(d).Equals("JWAIO-Sauvegardes",Comparison)) {
   Safe(p.Root,d); if(Directory.Exists(System.IO.Path.Combine(d,"WIDGETS"))) ScanBase(p,d);
  }}
  p.Files=p.Files.OrderBy(f=>f.Path,StringComparer.OrdinalIgnoreCase).ToList(); return p;
 }
 public static bool Same(Plan a,Plan b) {
  return a.Root==b.Root && a.Files.Count==b.Files.Count && a.Files.Zip(b.Files,(x,y)=>x.Path==y.Path&&x.Hash==y.Hash&&x.Save==y.Save).All(x=>x) && a.Dirs.OrderBy(x=>x).SequenceEqual(b.Dirs.OrderBy(x=>x));
 }
 public static string Execute(Plan p) {
  var now=Scan(p.Root,p.Skins,p.Logs); if(!Same(p,now)) throw new IOException("Le contenu a changé. Relancez l’analyse avant de supprimer.");
  if(p.Files.Any(f=>(File.GetAttributes(f.Path)&FileAttributes.ReadOnly)!=0)) throw new IOException("Nettoyage interrompu avant suppression : un fichier est en lecture seule. Vérifiez la protection en écriture du stockage.");
  string exe=System.Reflection.Assembly.GetExecutingAssembly().Location;
  if(p.Files.Any(f=>f.Path.Equals(exe,Comparison))) throw new IOException("Déplacez Cleaner hors du dossier à supprimer.");
  string backup=null;
  if(p.Files.Any(f=>f.Save)) {
   string parent=System.IO.Path.Combine(p.Root,"JWAIO-Sauvegardes");
   if(Directory.Exists(parent)) Safe(p.Root,parent); else Directory.CreateDirectory(parent);
   backup=System.IO.Path.Combine(parent,DateTime.Now.ToString("yyyyMMdd-HHmmss")+"-"+Guid.NewGuid().ToString("N").Substring(0,8));
   Directory.CreateDirectory(backup); Safe(p.Root,backup);
   foreach(var f in p.Files.Where(f=>f.Save)) {
    Safe(p.Root,f.Path); string dest=System.IO.Path.Combine(backup,f.Relative);
    Directory.CreateDirectory(System.IO.Path.GetDirectoryName(dest)); Safe(p.Root,System.IO.Path.GetDirectoryName(dest));
    File.Copy(f.Path,dest,false); if(Hash(dest)!=f.Hash) throw new IOException("Sauvegarde non vérifiée. Aucun fichier d’origine n’a été supprimé.");
   }
  }
  if(!Same(p,Scan(p.Root,p.Skins,p.Logs))) throw new IOException("Le contenu a changé pendant la sauvegarde. Aucun original supprimé.");
  int done=0;
  try {
   foreach(var f in p.Files) { Safe(p.Root,f.Path); if(Hash(f.Path)!=f.Hash) throw new IOException("Fichier modifié pendant le nettoyage."); File.Delete(f.Path); done++; }
   foreach(string d in p.Dirs.OrderByDescending(x=>x.Length)) { Safe(p.Root,d); Directory.Delete(d,false); }
  } catch(Exception e) { throw new IOException("Nettoyage interrompu après "+done+" fichier(s). Les éléments restants n’ont pas été supprimés. "+(backup==null?"":"Skins sauvegardés : "+backup+". ")+e.Message,e); }
  return "Nettoyage terminé : "+done+" fichier(s) retiré(s).\r\n"+(backup==null?"":"Skins sauvegardés sur la radio :\r\n"+backup+"\r\n")+(p.Kept.Count==0?"":"Logs conservés : "+String.Join(", ",p.Kept)+"\r\n")+"\r\nRetirez JWAIO / SIXTY9 des écrans de vos modèles dans EdgeTX, puis éjectez la radio avant de la débrancher.";
 }
}
}
