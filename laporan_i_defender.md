# LAPORAN PROJEK I DEFENDER — FORMAT DKM

---

## ABSTRAK

&nbsp;&nbsp;&nbsp;&nbsp;Projek ini bertajuk **I Defender** merupakan sebuah sistem pengesanan pencerobohan fizikal secara masa nyata (*real-time physical intrusion detection system*) yang dibangunkan menggunakan *Raspberry Pi 4 Model B 8GB RAM*, *Raspberry Pi Camera Module 3* (*Camera Module V3*), perpustakaan pemprosesan imej *OpenCV* dan model pengesanan objek *YOLO* (*You Only Look Once*). Sistem ini direka untuk memantau sesebuah kawasan secara automatik, mengesan kehadiran manusia yang tidak dibenarkan dan mengeluarkan amaran secara serta-merta tanpa memerlukan pemantauan manual oleh manusia.

&nbsp;&nbsp;&nbsp;&nbsp;Metodologi pembangunan projek ini menggunakan Model Air Terjun (*Waterfall Model*) yang merangkumi fasa perancangan, analisis, rekabentuk, implementasi dan pengujian. Perkakasan utama yang digunakan ialah *Raspberry Pi 4 Model B 8GB*, *Camera Module V3*, kad *MicroSD 64GB* dan bekalan kuasa *USB-C 5V/3A*. Perisian yang digunakan pula ialah *Raspberry Pi OS 64-bit*, *Python 3*, *OpenCV 4*, model *YOLOv8 Nano* serta perpustakaan *Ultralytics* sebagai rangka kerja pengesanan objek.

&nbsp;&nbsp;&nbsp;&nbsp;Hasil projek menunjukkan bahawa sistem I Defender berjaya mengesan kehadiran manusia dalam kawasan yang dipantau dengan kadar ketepatan yang memuaskan dalam persekitaran makmal yang terkawal. Sistem ini berupaya memproses aliran video secara langsung (*live stream*), melukis kotak sempadan (*bounding box*) di sekeliling objek yang dikesan dan mencetuskan amaran apabila pencerobohan dikesan. Kesimpulannya, I Defender merupakan penyelesaian pemantauan keselamatan yang praktikal dan kos efektif, sesuai untuk kegunaan institusi kecil, pejabat dan premis yang memerlukan pengawasan automatik.

---

## BAB I

## PENGENALAN

---

### 1.1 PENGENALAN PROJEK

&nbsp;&nbsp;&nbsp;&nbsp;Projek I Defender merupakan sebuah sistem kamera keselamatan pintar yang mampu mengesan kehadiran manusia secara automatik menggunakan teknologi penglihatan komputer (*computer vision*). Sistem ini dibangunkan di atas platform *Raspberry Pi 4 Model B 8GB RAM* yang dilengkapi dengan *Raspberry Pi Camera Module V3* sebagai peranti penangkapan imej. Pemprosesan video dijalankan menggunakan perpustakaan *OpenCV* manakala pengesanan objek khususnya pengesanan manusia dilakukan menggunakan model *YOLOv8 Nano* yang dioptimumkan untuk berjalan pada perkakasan berdaya rendah.

&nbsp;&nbsp;&nbsp;&nbsp;Sistem perakam keselamatan (*CCTV*) konvensional yang sedia ada hanya berfungsi sebagai peranti rakaman pasif yang memerlukan pemantauan manusia secara berterusan untuk mengesan sebarang kejadian yang mencurigakan. Pendekatan ini tidak cekap dan tidak praktikal terutamanya bagi premis yang tidak mempunyai kakitangan keselamatan yang mencukupi. I Defender hadir sebagai penyelesaian kepada masalah ini dengan menggabungkan keupayaan rakaman video bersama pengesanan objek secara automatik dalam satu sistem yang padat, berkos rendah dan mudah dipasang. Jangkaan hasil projek ini ialah sebuah sistem yang dapat beroperasi secara berterusan selama 24 jam, mengesan kehadiran manusia dalam masa kurang dari satu saat dan menghantar amaran kepada pentadbir apabila pencerobohan dikesan.

---

### 1.2 LATARBELAKANG MASALAH

&nbsp;&nbsp;&nbsp;&nbsp;Keselamatan premis merupakan satu keperluan asas bagi setiap organisasi, institusi pendidikan dan perniagaan. Sistem kamera keselamatan (*CCTV*) konvensional telah lama digunakan sebagai kaedah pengawasan, namun sistem ini mempunyai beberapa kelemahan yang ketara. Kajian dan pemerhatian yang dijalankan mendapati bahawa kebanyakan sistem *CCTV* yang dipasang hanya berfungsi sebagai alat rakaman pasif dan tidak mampu memberikan tindak balas atau amaran secara automatik apabila berlaku pencerobohan.

&nbsp;&nbsp;&nbsp;&nbsp;Masalah pertama yang dikenal pasti ialah ketidakupayaan sistem *CCTV* sedia ada untuk mengesan pencerobohan secara automatik. Pemantauan rakaman *CCTV* memerlukan kehadiran manusia secara berterusan, iaitu satu keperluan yang mahal dan tidak praktikal. Masalah kedua ialah sistem penggera keselamatan konvensional yang berasaskan penderia gerakan (*PIR sensor*) tidak mampu membezakan antara manusia, haiwan atau objek bergerak lain, menyebabkan berlakunya amaran palsu (*false alarm*) yang kerap. Masalah ketiga ialah kos sistem kamera keselamatan pintar komersial yang dilengkapi keupayaan pengesanan automatik adalah sangat tinggi, menjadikannya di luar kemampuan institusi kecil dan perniagaan berskala kecil.

&nbsp;&nbsp;&nbsp;&nbsp;Berdasarkan masalah-masalah yang dikenal pasti ini, satu keperluan jelas wujud untuk membangunkan sistem pemantauan keselamatan yang berupaya mengesan kehadiran manusia secara automatik, membezakan manusia daripada objek lain, memberikan amaran serta-merta dan boleh dibangunkan dengan kos yang rendah. Projek I Defender dibangunkan untuk memenuhi keperluan ini dengan memanfaatkan perkakasan *Raspberry Pi 4 8GB* dan model pengesanan objek *YOLO* yang berjalan di atas perpustakaan *OpenCV*.

---

### 1.3 OBJEKTIF PROJEK

&nbsp;&nbsp;&nbsp;&nbsp;Objektif kajian adalah seperti berikut:

i) Membangunkan sistem pengesanan kehadiran manusia secara masa nyata menggunakan *Raspberry Pi 4 Model B 8GB*, *Raspberry Pi Camera Module V3*, perpustakaan *OpenCV 4* dan model pengesanan objek *YOLOv8 Nano* yang mampu memproses aliran video langsung dengan kadar bingkai (*frame rate*) yang mencukupi untuk tujuan pemantauan keselamatan.

ii) Mengkonfigurasi dan melatih semula (*fine-tune*) model *YOLOv8* agar mampu mengesan kehadiran manusia dengan tepat dalam pelbagai keadaan pencahayaan dan sudut pandangan dalam persekitaran makmal, serta memaparkan kotak sempadan (*bounding box*) dan paras keyakinan (*confidence score*) pada setiap objek yang dikesan.

iii) Membangunkan modul amaran automatik yang akan mencetuskan pemberitahuan kepada pentadbir sistem apabila kehadiran manusia dikesan di dalam kawasan yang dipantau, termasuk merekodkan tangkapan gambar (*snapshot*) berserta cap masa (*timestamp*) sebagai bukti kejadian.

---

### 1.4 SKOP PROJEK

&nbsp;&nbsp;&nbsp;&nbsp;Bagi mencapai matlamat dan objektif yang digariskan, beberapa skop projek telah dikenalpasti.

&nbsp;&nbsp;&nbsp;&nbsp;Antaranya ialah:

i. Projek ini meliputi pembangunan, konfigurasi dan pengujian sistem I Defender untuk memantau satu kawasan dalaman (*indoor*) sahaja, iaitu kawasan makmal komputer di E-Access International College, dengan satu unit kamera *Camera Module V3* yang dipasang pada satu sudut pandangan tetap.

ii. Batasan dari segi pengesanan objek adalah tertumpu kepada pengesanan kelas manusia (*person class*) sahaja berdasarkan set data model *YOLOv8*, dan tidak merangkumi pengesanan objek lain seperti kenderaan, haiwan atau barang.

iii. Batasan dari segi tempoh adalah selama empat (4) bulan, bermula dari bulan Januari hingga April, yang merangkumi keseluruhan fasa perancangan, pembangunan, pengujian dan dokumentasi projek.

iv. Sistem I Defender dibangunkan menggunakan bahasa pengaturcaraan *Python 3* dan tidak merangkumi pembangunan aplikasi mudah alih (*mobile application*) atau antaramuka web yang kompleks.

v. Pengujian sistem dijalankan dalam persekitaran makmal yang terkawal dengan keadaan pencahayaan biasa (*normal indoor lighting*) dan tidak merangkumi pengujian dalam keadaan cahaya rendah (*low light*) atau persekitaran luar (*outdoor*).

---

## BAB II

## METODOLOGI

---

### 2.1 PENGENALAN

&nbsp;&nbsp;&nbsp;&nbsp;Bab ini akan menerangkan secara terperinci kaedah-kaedah yang digunakan dan aliran keseluruhan projek I Defender dari peringkat perancangan sehinggalah pengujian. Penerangan merangkumi susun atur (*set-up*) perkakasan iaitu *Raspberry Pi 4 Model B 8GB* dan *Camera Module V3*, konfigurasi persekitaran perisian *Python*, *OpenCV* dan *YOLOv8*, serta aliran pemprosesan video dan pengesanan objek yang menjadi teras kepada fungsi sistem ini. Langkah-langkah pengubahsuaian (*troubleshooting*) yang diambil semasa fasa implementasi turut diterangkan bagi memberikan gambaran yang lengkap tentang proses pembangunan sistem.

---

### 2.2 SUSUN ATUR PROJEK

&nbsp;&nbsp;&nbsp;&nbsp;Projek I Defender menggunakan **Model Air Terjun (*Waterfall Model*)** sebagai rangka kerja pembangunan. Pendekatan ini dipilih kerana keperluan sistem telah dikenal pasti dengan jelas sejak awal, dan setiap fasa pembangunan mempunyai hasil (*deliverable*) yang boleh disahkan sebelum fasa seterusnya dimulakan. Model ini juga memudahkan pengurusan masa dan sumber dalam tempoh empat bulan yang ditetapkan.

**Fasa 1: Perancangan (*Planning*)**

&nbsp;&nbsp;&nbsp;&nbsp;Pada fasa ini, skop projek ditetapkan, keperluan perkakasan dan perisian dikenal pasti, dan jadual pelaksanaan dalam bentuk Carta Gantt disediakan. Sesi perbincangan bersama penyelia dijalankan untuk memastikan hala tuju projek adalah tepat. Kajian awal terhadap keupayaan *Raspberry Pi 4* dalam memproses video masa nyata dan menjalankan model *YOLO* turut dilaksanakan pada fasa ini bagi memastikan perkakasan yang dipilih mampu memenuhi keperluan prestasi sistem.

**Fasa 2: Analisis Sistem (*System Analysis*)**

&nbsp;&nbsp;&nbsp;&nbsp;Fasa analisis melibatkan kajian mendalam terhadap teknologi pengesanan objek yang sesuai untuk digunakan pada platform *Raspberry Pi 4*. Kajian perbandingan antara pelbagai versi model *YOLO* iaitu *YOLOv5*, *YOLOv7* dan *YOLOv8* dijalankan dari segi ketepatan pengesanan (*detection accuracy*), kelajuan pemprosesan (*inference speed*) dan penggunaan memori pada seni bina *ARM Cortex-A72* milik *Raspberry Pi 4*. Hasil analisis mendapati *YOLOv8 Nano* (*YOLOv8n*) adalah pilihan terbaik kerana menawarkan keseimbangan yang baik antara kelajuan dan ketepatan pengesanan pada perkakasan berdaya rendah. *Camera Module V3* pula dipilih sebagai kamera kerana menyokong resolusi sehingga 12 megapiksel dan mempunyai antara muka *CSI* (*Camera Serial Interface*) yang terus disambungkan ke *Raspberry Pi 4* tanpa memerlukan pemacu tambahan.

**Fasa 3: Rekabentuk Sistem (*System Design*)**

&nbsp;&nbsp;&nbsp;&nbsp;Rekabentuk sistem I Defender merangkumi tiga komponen utama iaitu komponen penangkapan video, komponen pemprosesan dan pengesanan, serta komponen amaran. Aliran kerja sistem adalah seperti berikut: *Camera Module V3* menangkap aliran video secara berterusan, setiap bingkai video (*frame*) diterima oleh *OpenCV* untuk pra-pemprosesan (*preprocessing*) termasuk pengubahsuaian saiz (*resizing*) dan penukaran ruang warna (*color space conversion*), bingkai yang telah diproses dihantar kepada model *YOLOv8n* untuk pengesanan objek, hasil pengesanan berupa koordinat kotak sempadan (*bounding box coordinates*) dan nilai keyakinan (*confidence value*) dikembalikan, dan akhirnya apabila manusia dikesan dengan nilai keyakinan melebihi ambang yang ditetapkan (*confidence threshold*), sistem akan mencetuskan amaran dan merekodkan tangkapan gambar berserta cap masa.

**Fasa 4: Implementasi (*Implementation*)**

&nbsp;&nbsp;&nbsp;&nbsp;Pelaksanaan implementasi dimulakan dengan pemasangan sistem operasi *Raspberry Pi OS 64-bit (Bookworm)* pada kad *MicroSD 64GB* menggunakan perisian *Raspberry Pi Imager*. Setelah sistem operasi berjalan, persekitaran *Python 3.11* dikonfigurasikan dan semua pakej yang diperlukan dipasang menggunakan pengurus pakej *pip*, termasuk *OpenCV-Python*, perpustakaan *Ultralytics* untuk *YOLOv8* dan pakej *picamera2* untuk mengawal *Camera Module V3*. Model *YOLOv8n* dimuat turun dan diuji pada peringkat awal menggunakan beberapa imej ujian bagi memastikan pengesanan berfungsi dengan betul sebelum integrasi penuh dengan aliran video langsung dijalankan. Kod pengaturcaraan utama sistem ditulis dalam bahasa *Python* menggunakan pendekatan pengaturcaraan berorientasikan objek (*OOP*) bagi memudahkan penyelenggaraan dan pengubahsuaian pada masa hadapan.

**Fasa 5: Pengujian (*Testing*)**

&nbsp;&nbsp;&nbsp;&nbsp;Pengujian sistem dijalankan melalui beberapa senario yang berbeza. Ujian pertama ialah ujian pengesanan statik (*static detection test*) di mana beberapa orang individu diminta berdiri di hadapan kamera pada jarak yang berbeza-beza untuk mengesahkan keupayaan sistem mengesan manusia dari pelbagai jarak. Ujian kedua ialah ujian pengesanan dinamik (*dynamic detection test*) di mana individu diminta bergerak melintas di hadapan kamera untuk menguji keupayaan sistem mengesan gerakan. Ketepatan pengesanan, kadar amaran palsu (*false positive rate*) dan kadar bingkai pemprosesan (*frames per second* / FPS) direkodkan dan dianalisis bagi setiap senario ujian.

**Keperluan Perkakasan:**

| Bil | Perkakasan | Spesifikasi | Kuantiti |
|-----|-----------|-------------|---------|
| 1 | Raspberry Pi 4 Model B | 8GB LPDDR4X RAM, ARM Cortex-A72 @ 1.8GHz | 1 unit |
| 2 | Raspberry Pi Camera Module V3 | 12MP Sony IMX708, Sudut Pandangan 66° | 1 unit |
| 3 | Kad MicroSD | 64GB, Kelas 10 / A2, Kelajuan Baca ≥ 90MB/s | 1 keping |
| 4 | Bekalan Kuasa USB-C | 5V / 3A (15W) | 1 unit |
| 5 | Kabel CSI | 15cm, untuk sambungan Camera Module ke Pi | 1 utas |
| 6 | Casing Raspberry Pi | Dengan soket kamera, penyejuk udara | 1 unit |
| 7 | Monitor / Skrin | Untuk paparan semasa pengujian | 1 unit |
| 8 | Komputer Riba | Untuk pembangunan kod dan pemindahan fail | 1 unit |

**Keperluan Perisian:**

| Bil | Perisian / Pustaka | Versi | Fungsi |
|-----|-------------------|-------|--------|
| 1 | Raspberry Pi OS 64-bit | Bookworm (Debian 12) | Sistem Operasi Utama |
| 2 | Python | 3.11 | Bahasa Pengaturcaraan Utama |
| 3 | OpenCV-Python | 4.8.x | Pemprosesan dan Analisis Video |
| 4 | Ultralytics (YOLOv8) | 8.x | Rangka Kerja Pengesanan Objek |
| 5 | YOLOv8n Model | yolov8n.pt | Model Pengesanan Objek (Nano) |
| 6 | picamera2 | 0.3.x | Kawalan Raspberry Pi Camera Module V3 |
| 7 | NumPy | 1.24.x | Operasi Tatasusunan dan Matriks |
| 8 | Thonny IDE | 4.x | Persekitaran Pembangunan Kod |

---

### KESIMPULAN

&nbsp;&nbsp;&nbsp;&nbsp;Secara keseluruhannya, Bab II ini telah menerangkan dengan terperinci metodologi dan susun atur yang digunakan dalam pembangunan projek I Defender. Pemilihan *Raspberry Pi 4 Model B 8GB* sebagai platform pemprosesan utama terbukti mampu menampung keperluan pengesanan objek masa nyata menggunakan *YOLOv8 Nano* dengan prestasi yang memuaskan. Kamera *Camera Module V3* pula menyediakan kualiti imej yang tinggi dan integrasi yang lancar dengan platform *Raspberry Pi*, manakala gabungan *OpenCV* dan *YOLOv8* membentuk saluran pemprosesan (*processing pipeline*) yang cekap untuk tujuan pengesanan kehadiran manusia.

&nbsp;&nbsp;&nbsp;&nbsp;Pemilihan Model Air Terjun (*Waterfall Model*) sebagai rangka kerja pembangunan memastikan setiap fasa dilaksanakan secara sistematik dan teratur dalam tempoh empat bulan yang ditetapkan. Susun atur perkakasan yang padat, penggunaan perisian *open-source* yang terbukti berkesan, serta prosedur pengujian yang komprehensif merupakan faktor-faktor utama yang menyumbang kepada kelancaran pembangunan sistem I Defender. Hasil implementasi dan analisis keputusan pengujian akan dibincangkan dengan lebih lanjut dalam bab seterusnya.

---

*[Nota Format DKM: Times New Roman Saiz 12, 1.5 Spacing, Justified, Tab 1 kali awal perenggan, Margin Kiri 1.25" Kanan 1.0" Atas Bawah 1.0", Header & Footer 0.5"]*
