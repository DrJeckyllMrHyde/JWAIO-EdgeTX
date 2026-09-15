using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Runtime.InteropServices;

namespace JwaioCleaner {
public class CleanerForm : Form {
 Color panel=Color.FromArgb(13,26,42), blue=Color.FromArgb(0,174,255), orange=Color.FromArgb(255,150,27);
 ComboBox drives; CheckBox skins,logs; Button scan,clean,refresh,browse; TextBox details; Label state,summary; Plan plan; bool busy;
 Image background,logo;
 [DllImport("kernel32.dll",CharSet=CharSet.Unicode)] static extern uint GetDriveType(string root);
 [DllImport("kernel32.dll",CharSet=CharSet.Unicode)] static extern bool GetVolumeInformation(string root,System.Text.StringBuilder name,int size,out uint serial,out uint max,out uint flags,System.Text.StringBuilder fs,int fsSize);
 uint serial; string selectedRoot; int detectionGeneration;
 sealed class DriveChoice {public string Root,Name;public override string ToString(){return Name;}}
 public CleanerForm() {
  Text="JWAIO Cleaner • 0.1 Preview"; ClientSize=new Size(1000,750); MinimumSize=new Size(900,720); StartPosition=FormStartPosition.CenterScreen;
  AutoScaleMode=AutoScaleMode.Dpi; Font=new Font("Segoe UI",10); ForeColor=Color.White; BackColor=Color.FromArgb(7,15,26); DoubleBuffered=true;
  background=Image.FromStream(Assembly.GetExecutingAssembly().GetManifestResourceStream("background.png"));
  logo=Image.FromStream(Assembly.GetExecutingAssembly().GetManifestResourceStream("logo.png"));
  using(var iconBitmap=new Bitmap(logo,new Size(32,32))){IntPtr h=iconBitmap.GetHicon();Icon=(Icon)Icon.FromHandle(h).Clone();DestroyIcon(h);}
  var top=new Panel{Dock=DockStyle.Top,Height=160};
  top.Paint+=(s,e)=> {e.Graphics.DrawImage(background,new Rectangle(0,0,top.Width,top.Height)); using(var b=new SolidBrush(Color.FromArgb(75,0,5,15)))e.Graphics.FillRectangle(b,top.ClientRectangle); e.Graphics.DrawImage(logo,new Rectangle(28,28,100,100)); using(var p=new Pen(blue,2)) e.Graphics.DrawLine(p,28,158,top.Width-28,158);};
  top.Controls.Add(Label("JWAIO",148,15,400,66,44,true)); top.Controls.Add(Label("CLEANER",152,78,400,36,22,true));
  var sub=Label("UNE RADIO PROPRE. VOS VOLS PRÉSERVÉS.",154,121,700,25,10,false); sub.ForeColor=orange;top.Controls.Add(sub);
  Controls.Add(top);
  var body=new TableLayoutPanel{Dock=DockStyle.Fill,Padding=new Padding(28,16,28,16),ColumnCount=1,RowCount=9};
  body.RowStyles.Add(new RowStyle(SizeType.Absolute,28));body.RowStyles.Add(new RowStyle(SizeType.Absolute,42));body.RowStyles.Add(new RowStyle(SizeType.Absolute,38));body.RowStyles.Add(new RowStyle(SizeType.Absolute,70));body.RowStyles.Add(new RowStyle(SizeType.Absolute,36));body.RowStyles.Add(new RowStyle(SizeType.Absolute,30));body.RowStyles.Add(new RowStyle(SizeType.Percent,100));body.RowStyles.Add(new RowStyle(SizeType.Absolute,52));body.RowStyles.Add(new RowStyle(SizeType.Absolute,30));
  Controls.Add(body); body.BringToFront();
  body.Controls.Add(new Label{Text="01  CONNECTEZ LA RADIO EN MODE STOCKAGE USB",Dock=DockStyle.Fill,ForeColor=blue,Font=new Font(Font,FontStyle.Bold)},0,0);
  var row=new TableLayoutPanel{Dock=DockStyle.Fill,ColumnCount=3};row.ColumnStyles.Add(new ColumnStyle(SizeType.Percent,100));row.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute,136));row.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute,160));
  drives=new ComboBox{Dock=DockStyle.Fill,DropDownStyle=ComboBoxStyle.DropDownList,BackColor=panel,ForeColor=Color.White}; drives.SelectedIndexChanged+=(s,e)=>InvalidatePlan();
  refresh=Button("Actualiser",()=>Detect());browse=Button("Choisir un dossier",()=>Choose());row.Controls.Add(drives);row.Controls.Add(refresh);row.Controls.Add(browse);body.Controls.Add(row,0,1);
  state=new Label{Text="Recherche des lecteurs…",Dock=DockStyle.Fill,ForeColor=Color.Silver,Padding=new Padding(0,8,0,0)};body.Controls.Add(state,0,2);
  var options=new TableLayoutPanel{Dock=DockStyle.Fill,BackColor=panel,ColumnCount=2,Padding=new Padding(12,8,12,8)};options.ColumnStyles.Add(new ColumnStyle(SizeType.Percent,50));options.ColumnStyles.Add(new ColumnStyle(SizeType.Percent,50));
  skins=new CheckBox{Text="Conserver mes skins\r\nCopie vérifiée sur la radio",Checked=true,Dock=DockStyle.Fill,AutoSize=false};logs=new CheckBox{Text="Conserver mes logs de vol\r\nConservés à leur emplacement",Checked=true,Dock=DockStyle.Fill,AutoSize=false};
  skins.CheckedChanged+=(s,e)=>InvalidatePlan();logs.CheckedChanged+=(s,e)=>InvalidatePlan();options.Controls.Add(skins);options.Controls.Add(logs);body.Controls.Add(options,0,3);
  body.Controls.Add(new Label{Text="02  VÉRIFIEZ CE QUI SERA RETIRÉ",Dock=DockStyle.Fill,ForeColor=blue,Padding=new Padding(0,12,0,0),Font=new Font(Font,FontStyle.Bold)},0,4);
  summary=new Label{Text="JWAIO et anciennes versions SIXTY9 • Analyse ciblée",Dock=DockStyle.Fill,Padding=new Padding(0,5,0,0)};body.Controls.Add(summary,0,5);
  details=new TextBox{Dock=DockStyle.Fill,Multiline=true,ReadOnly=true,ScrollBars=ScrollBars.Both,WordWrap=false,BackColor=panel,ForeColor=Color.FromArgb(206,221,237),BorderStyle=BorderStyle.FixedSingle,Font=new Font("Consolas",9),Text="Branchez votre radio, sélectionnez son stockage puis cliquez sur Analyser.\r\n\r\nLes autres widgets, modèles et sons communs sont conservés.\r\nAucun fichier n’est supprimé pendant l’analyse."};body.Controls.Add(details,0,6);
  var actions=new TableLayoutPanel{Dock=DockStyle.Fill,ColumnCount=2,Padding=new Padding(0,8,0,0)};actions.ColumnStyles.Add(new ColumnStyle(SizeType.Percent,42));actions.ColumnStyles.Add(new ColumnStyle(SizeType.Percent,58));scan=Button("Analyser la radio",async()=>await Analyze());clean=Button("Vérifier et supprimer…",async()=>await Clean());clean.BackColor=orange;clean.ForeColor=Color.Black;clean.Enabled=false;actions.Controls.Add(scan);actions.Controls.Add(clean);body.Controls.Add(actions,0,7);
  body.Controls.Add(new Label{Text="PORTABLE  /  SANS INSTALLATION  /  HORS LIGNE     •     v0.1 Preview",ForeColor=Color.SlateGray,Dock=DockStyle.Fill,Padding=new Padding(0,10,0,0),Font=new Font("Segoe UI",8)},0,8);
  Shown+=(s,e)=>Detect(); FormClosing+=(s,e)=>{if(busy){e.Cancel=true;state.Text="Veuillez attendre la fin de l’opération avant de fermer.";}};
 }
 Label Label(string text,int x,int y,int w,int h,int size,bool bold) {return new Label{Text=text,Bounds=new Rectangle(x,y,w,h),BackColor=Color.Transparent,Font=new Font(bold?"Impact":"Segoe UI",size,bold?FontStyle.Regular:FontStyle.Regular)};}
 Button Button(string text,Action click) {var b=new Button{Text=text,Dock=DockStyle.Fill,BackColor=panel,ForeColor=Color.White,FlatStyle=FlatStyle.Flat,Cursor=Cursors.Hand,Margin=new Padding(4,0,0,2)};b.FlatAppearance.BorderColor=blue;b.Click+=(s,e)=>click();return b;}
 void SetBusy(bool value) {busy=value;scan.Enabled=!value&&drives.Items.Count>0;refresh.Enabled=browse.Enabled=drives.Enabled=skins.Enabled=logs.Enabled=!value;clean.Enabled=!value&&plan!=null&&plan.Files.Count>0;}
 void InvalidatePlan(){plan=null;if(clean!=null)clean.Enabled=false;if(summary!=null)summary.Text="Relancez l’analyse pour vérifier votre sélection.";}
 [DllImport("user32.dll")] static extern bool DestroyIcon(IntPtr icon);
 void Detect() {
  if(busy)return; InvalidatePlan();int generation=++detectionGeneration;var old=drives.SelectedItem as DriveChoice;drives.Items.Clear();
  foreach(string d in Environment.GetLogicalDrives()) {uint t=GetDriveType(d);if(t==2||t==3)drives.Items.Add(new DriveChoice{Root=d,Name=d+" — "+(t==2?"Stockage amovible":"Lecteur")});}
  if(old!=null)foreach(DriveChoice item in drives.Items)if(item.Root==old.Root)drives.SelectedItem=item;
  state.Text=drives.Items.Count+" lecteur(s) disponible(s). Choisissez le stockage de la radio.";scan.Enabled=drives.Items.Count>0;
  summary.Text="JWAIO et anciennes versions SIXTY9 • Analyse ciblée";
  foreach(DriveChoice item in drives.Items.Cast<DriveChoice>().ToArray()) IdentifyDrive(item,generation);
 }
 async void IdentifyDrive(DriveChoice item,int generation){
  bool found=await Task.Run(()=>Directory.Exists(Path.Combine(item.Root,"WIDGETS","JWAIO"))||Directory.Exists(Path.Combine(item.Root,"WIDGETS","SIXTY9")));
  if(IsDisposed||busy||generation!=detectionGeneration||!found)return;
  int i=drives.Items.IndexOf(item);if(i<0)return;item.Name=item.Root+" — Radio / JWAIO détecté";drives.Items[i]=item;
  if(drives.SelectedItem==null)drives.SelectedItem=item;state.Text="Stockage JWAIO détecté. Vérifiez le lecteur puis lancez l’analyse.";
 }
 protected override void WndProc(ref Message m) {base.WndProc(ref m); if(m.Msg==0x0219&&!busy&&drives!=null) Detect();}
 void Choose(){using(var d=new FolderBrowserDialog{Description="Sélectionnez la racine du stockage EdgeTX (contient WIDGETS).",ShowNewFolderButton=false})if(d.ShowDialog(this)==DialogResult.OK){var item=new DriveChoice{Root=d.SelectedPath,Name=d.SelectedPath};drives.Items.Add(item);drives.SelectedItem=item;}}
 uint Volume(string path){uint id,max,flags;if(!GetVolumeInformation(Path.GetPathRoot(path),null,0,out id,out max,out flags,null,0))throw new IOException("Le volume n’est pas disponible.");return id;}
 async Task Analyze(){
  if(drives.SelectedItem==null){state.Text="Sélectionnez d’abord le lecteur de la radio.";return;}
  string root=((DriveChoice)drives.SelectedItem).Root;bool ks=skins.Checked,kl=logs.Checked;InvalidatePlan();SetBusy(true);state.Text="Analyse des seuls dossiers JWAIO et SIXTY9…";
  try {serial=Volume(root);selectedRoot=root;plan=await Task.Run(()=>Engine.Scan(root,ks,kl));
   details.Text="VOLUME : "+plan.Root+"\r\n\r\n"+String.Join("\r\n",plan.Found.Select(x=>"DOSSIER  "+x))+"\r\n\r\n"+String.Join("\r\n",plan.Files.Select(f=>(f.Save?"SAUVEGARDER PUIS RETIRER  ":"SUPPRIMER  ")+f.Relative))+"\r\n\r\n"+String.Join("\r\n",plan.Kept.Select(x=>"CONSERVER  "+x));
   summary.Text=plan.Files.Count+" fichier(s) à retirer • "+(plan.Bytes/1048576.0).ToString("0.00")+" Mo • "+plan.Files.Count(f=>f.Save)+" à sauvegarder";
   state.Text=plan.Files.Count==0?"Aucun fichier à supprimer selon vos choix.":"Analyse terminée. Vérifiez la liste avant de continuer.";
  }catch(Exception e){plan=null;state.Text="Analyse interrompue";details.Text=e.Message;}finally{SetBusy(false);}
 }
 async Task Clean(){if(plan==null)return;
  var p=plan;
  string msg="Stockage : "+p.Root+"\r\n\r\n"+p.Files.Count+" fichier(s) seront retirés définitivement.\r\n"+(p.Skins?"Skins : sauvegardés et vérifiés sur la radio.\r\n":"Skins : SUPPRIMÉS sans sauvegarde.\r\n")+(p.Logs?"Logs : conservés.\r\n":"Logs : SUPPRIMÉS sans sauvegarde.\r\n")+"\r\nLa suppression ne passe pas par la Corbeille.\r\nConfirmez-vous le nettoyage de ce stockage ?";
  if(MessageBox.Show(this,msg,"Confirmer la suppression",MessageBoxButtons.YesNo,MessageBoxIcon.Warning,MessageBoxDefaultButton.Button2)!=DialogResult.Yes)return;
  SetBusy(true);state.Text="Vérification et nettoyage en cours. Ne débranchez pas la radio.";
  try{if(Volume(selectedRoot)!=serial)throw new IOException("Le volume a changé. Relancez l’analyse.");details.Text=await Task.Run(()=>Engine.Execute(p));state.Text="Nettoyage terminé";summary.Text="Vous pouvez maintenant éjecter votre radio.";}
  catch(Exception e){state.Text="Nettoyage interrompu";details.Text=e.Message;}finally{plan=null;SetBusy(false);}
 }
 public void RenderPreview(string path){using(var bmp=new Bitmap(Width,Height)){DrawToBitmap(bmp,new Rectangle(0,0,Width,Height));bmp.Save(path);}}
 protected override void Dispose(bool disposing){if(disposing){if(background!=null)background.Dispose();if(logo!=null)logo.Dispose();}base.Dispose(disposing);}
}
static class Program {
 [STAThread] static void Main(string[] args){Application.EnableVisualStyles();Application.SetCompatibleTextRenderingDefault(false);using(var f=new CleanerForm()){if(args.Length==2&&args[0]=="--render-preview"){f.Show();Application.DoEvents();f.RenderPreview(args[1]);return;}Application.Run(f);}}
}
}
