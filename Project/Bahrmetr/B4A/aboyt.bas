B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=11.2
@EndOfDesignText@
Sub Class_Globals
	Private Root As B4XView 'ignore
	Private xui As XUI 'ignore
	Private Label1 As Label
End Sub

'You can add more parameters here.
Public Sub Initialize As Object
	Return Me
End Sub

'This event will be called once, before the page becomes visible.
Private Sub B4XPage_Created (Root1 As B4XView)
	Root = Root1
	'load the layout to Root
	Root1.LoadLayout("about")
	update
End Sub


Sub update
	If Label1.IsInitialized Then
		If B4XPages.MainPage.dil="Azərbaycanca" Then
			Label1.Text=$""Bahrmetr" mobil tətbiqi, nəzm ədəbiyyatında istifadə edilən Əruz vəzninin bəhrlərini tapmaqda vasitə rolunu oynayır. Tətbiq 12 bəhr və  80-ə yaxın qəlibi müəyyən edə bilər. Proqram mətiqini qurulması zamanı Əruz vəzni ilə bağlı əsas mənbə kimi Şirvani Ədillinin "ƏRUZ VƏZNİNİN SADƏLƏŞDİRİLMİŞ QƏLİBLƏRİ" kitabıda istifadə olunub.

İstifadəyə dair:
Şeir və ya qəzəl daxilindəki misralarda bəhrlərin tətbiqi müxtəlif üsullarla (imalələr, zihaflar və.s) həyata keçirilə bildiyindən, yalnız bir misraya əsasən bəhrin tapılmasındakı doğruluq ehtimalı daha azdır. Buna görə tətbiqə ən az üç misra daxil edilməsi mütləqdir.(Eyni misranın bir neçə dəfə daxil edilməsi doğruluq ehtimalını artırmır.)
Üç misradan hər hansı birinə tamamilə uyğun gələn qəlib tapıldıqda, bu dəqiq nəticə kimi qeyd ediləcək. Əks halda ən uyğun nəticə qeyd ediləcək.
Daxil edilən misraların tərkibində qeyri-latın simvollardan (å, ǻ, ḁ, ǜ, ǘ, ǚ, ĕ, ḝ, ȇ) istifadə edilməməsi məsləhətdir, bunun əvəzində uyğun latın simvollardan (a, u, e) istifadə edilə bilər."$
	
		Else if B4XPages.MainPage.dil="English" Then
			Label1.Text=$"Through the "Bahrmetr" application, you can find the type and patterns of aruz prosody often used in divan literature and ghazals.

User guide:

Since different techniques can be used in the use of aruz prosody in poems and ghazals (zihaflar, ulemas, allusions, etc.), the probability of finding a meter with a single verse will not be much. For this reason, you should enter at least three different verses in the application. The order of the verses in the poem may not be consecutive.
When the type of meter that is completely suitable for each of the three lines is found, the application will show it as a definitive result. Otherwise, the most probable meter type suitable for the verse will be shown.
It is recommended that you alter the non-typical latin characters that can be found in the verse with their standard counterparts (à-a, é-e, ŭ-u)."$
		Else
			Label1.Text=$""Bahrmetr" uygulaması sayesinde, sıklıkda divan edebiyyatında, gazellerde kullanılan aruz vezninin türünü və kalıblarını bula bilirsiniz.

Kullanım rehberi:

Şiir ve gazellerde aruzun kullanılmasında farklı teknikler kullanıla bildiğinden (zihaflar, ulemalar, imaleler v.b.) tek mısra ile veznin bulunmasında kesinlik ihtimalı fazla olmayacaktır. Bu sebepden uygulamaya en az üç farklı mısra girmelisiniz. Mısraların şiir içerisindeki sıralaması ardışık olmaya bilir.
Üç mısradan her hengi birine tamamen uygun vezn türü bulunduğunda uygulama bunu kesin sonuç olarak gösterecektir. Aksi takdirde mısralara uygun en mühtemel vezn türü gösterilecektir.
Mısra dahilinde buluna bilen imgeli karakterleri imgesiz benzeleri ile evezlemeniz tavsiye ediliyor.(à-a, é-e,ŭ-u)"$
		End If
	End If
End Sub
'You can see the list of page related events in the B4XPagesManager object. The event name is B4XPage.