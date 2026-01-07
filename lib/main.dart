import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
  theme: ThemeData(fontFamily: 'Noto Sans KR'),
  home: BuddyMainApp(),
  debugShowCheckedModeBanner: false,
));

class BuddyMainApp extends StatefulWidget {
  @override
  _BuddyMainAppState createState() => _BuddyMainAppState();
}

class _BuddyMainAppState extends State<BuddyMainApp> {
  final PageController _mainController = PageController();
  final PageController _personaController = PageController();
  int _currentPersonaIndex = 0;
  
  final List<Map<String, dynamic>> personaData = [
    {
      'type': 'F-type',
      'title': '따뜻한 위로가 필요할 때!',
      'sub': '따뜻한 격려와 공감으로 지치지 않고\n즐겁게 아끼는 습관을 만들어 드릴게요.',
      'color': Color(0xFFD4734B),
      'grad': [Color(0xFFFFFBEA), Color(0xFFFEF0F1)],
      'image': 'assets/images/character_f.png', // 👈 PNG 파일 경로 정의
    },
    {
      'type': 'S-type',
      'title': '센스있는 밸런스가 필요할 때!',
      'sub': '상황에 맞는 유연한 조언으로 공감과 절약,\n두 마리 토끼를 다 잡는 소비를 이끌어낼게요.',
      'color': Color(0xFF6EA12A),
      'grad': [Color(0xFFF5FFEA), Color(0xFFCCFFCE)],
      'image': 'assets/images/character_s.png', // 👈 PNG 파일 경로 정의
    },
    {
      'type': 'T-type',
      'title': '뼈 때리는 팩트가 필요할 때!',
      'sub': '냉철한 데이터 분석과 팩트로 낭비 없는\n확실한 저축 목표를 달성하게 도와드려요.',
      'color': Color(0xFF47758B),
      'grad': [Color(0xFFF8FDFF), Color(0xFFDFDFFF)],
      'image': 'assets/images/character_t.png', // 👈 PNG 파일 경로 정의
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _mainController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          _buildLoginScreen(),
          _buildPersonaSelectionContainer(),
        ],
      ),
    );
  }

  // --- [화면 1] 로그인 화면 ---
  Widget _buildLoginScreen() {
    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFFFBEA), Color(0xFFEBFCF4)])),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet, color: Color(0xFF007955), size: 100),
          SizedBox(height: 32),
          Text('당신의 지갑을 위한 가장\n똑똑한 잔소리', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 100),
          _btn(text: '구글 로그인', color: Colors.white, textColor: Colors.black, isOutlined: true, 
            onTap: () => _mainController.animateToPage(1, duration: Duration(milliseconds: 500), curve: Curves.easeInOut)),
        ],
      ),
    );
  }

  // --- [화면 2] 페르소나 선택 영역 ---
  Widget _buildPersonaSelectionContainer() {
    return Stack(
      children: [
        PageView.builder(
          controller: _personaController,
          itemCount: personaData.length,
          onPageChanged: (index) => setState(() => _currentPersonaIndex = index),
          itemBuilder: (context, index) => _buildPersonaContent(personaData[index], index),
        ),
        if (_currentPersonaIndex > 0)
          Positioned(
            left: 10, top: MediaQuery.of(context).size.height * 0.45,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black26, size: 30),
              onPressed: () => _personaController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.ease),
            ),
          ),
        if (_currentPersonaIndex < personaData.length - 1)
          Positioned(
            right: 10, top: MediaQuery.of(context).size.height * 0.45,
            child: IconButton(
              icon: Icon(Icons.arrow_forward_ios_rounded, color: Colors.black26, size: 30),
              onPressed: () => _personaController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.ease),
            ),
          ),
      ],
    );
  }

  Widget _buildPersonaContent(Map<String, dynamic> data, int index) {
    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: data['grad'])),
      child: Column(
        children: [
          SizedBox(height: 80),
          Text('버디를 골라보세요', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
          SizedBox(height: 30),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: data['color'].withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(data['type'], style: TextStyle(color: data['color'], fontWeight: FontWeight.bold)),
          ),
          
          // ⭐ [이미지 교체 영역] 캐릭터 아이콘 -> PNG 이미지로 변경
          Expanded(
            child: Center(
              child: 
              /* [방법 1] 실제 PNG 이미지를 사용할 때 (광진 님께 전달용)
              Image.asset(
                data['image'], // personaData에 정의된 경로를 불러옵니다.
                width: 250,    // 디자인에 맞게 크기 조절
                fit: BoxFit.contain,
              ),
              */
              // [방법 2] 현재 DartPad 테스트용 (이미지가 없으므로 아이콘 유지)
              Icon(Icons.face_retouching_natural_rounded, size: 200, color: data['color']),
            ),
          ),
          
          Text(data['title'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(data['sub'], textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Color(0xFF495565), height: 1.5)),
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) => GestureDetector(
              onTap: () => _personaController.animateToPage(i, duration: Duration(milliseconds: 300), curve: Curves.ease),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4),
                width: (_currentPersonaIndex == i) ? 24 : 8, height: 8,
                decoration: BoxDecoration(
                  color: (_currentPersonaIndex == i) ? data['color'] : Colors.black12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            )),
          ),
          SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            child: _btn(
              text: '버디 선택 완료', 
              color: data['color'], 
              textColor: Colors.white, 
              onTap: () => print("${data['type']} 선택됨!"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _btn({required String text, required Color color, required Color textColor, bool isOutlined = false, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 300, height: 60,
          decoration: BoxDecoration(
            color: color, 
            borderRadius: BorderRadius.circular(16), 
            border: isOutlined ? Border.all(color: Color(0xFFD6D3D0)) : null,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]
          ),
          child: Center(child: Text(text, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold))),
        ),
      ),
    );
  }
} 