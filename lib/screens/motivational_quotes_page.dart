import 'package:flutter/material.dart';

class MotivationalQuotesPage extends StatelessWidget {
  const MotivationalQuotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Motivational Quotes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white, // Background color
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Center(
              child: Text(
                "Choose a Category",
                style: TextStyle(
                  color: Colors.blueAccent, // Text color
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto', // Stylish font
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildCategoryButton(context, 'Personal Growth', [Colors.lightGreen, Colors.greenAccent], personalGrowthQuotes),
                  _buildCategoryButton(context, 'Health & Wellness', [Colors.lightBlue, Colors.blueAccent], healthWellnessQuotes),
                  _buildCategoryButton(context, 'Career Growth', [Colors.orange, Colors.deepOrange], careerGrowthQuotes),
                  _buildCategoryButton(context, 'Relationships', [Colors.pinkAccent, Colors.deepPurple], relationshipsQuotes),
                  _buildCategoryButton(context, 'Resilience', [Colors.amber, Colors.orangeAccent], resilienceQuotes),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(BuildContext context, String category, List<Color> gradientColors, List<String> quotes) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: gradientColors[0],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryQuotesPage(
                category: category,
                gradientColors: gradientColors,
                quotes: quotes,
              ),
            ),
          );
        },
        child: Text(
          category,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontFamily: 'Lobster',
          ),
        ),
      ),
    );
  }
}

class CategoryQuotesPage extends StatelessWidget {
  final String category;
  final List<Color> gradientColors;
  final List<String> quotes;

  const CategoryQuotesPage({
    super.key,
    required this.category,
    required this.gradientColors,
    required this.quotes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$category Quotes',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: gradientColors[0], // Matches the category color
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white, // Background color
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: quotes.length,
          itemBuilder: (context, index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(25), // Replaced deprecated withOpacity
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: const Icon(
                  Icons.format_quote,
                  color: Colors.black87,
                  size: 30,
                ),
                title: Text(
                  quotes[index],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontFamily: 'Merriweather', // Stylish font for quotes
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Predefined quotes for each category
const personalGrowthQuotes = [
  "Strive not to be a success, but rather to be of value. – Albert Einstein",
  "Be yourself; everyone else is already taken. – Oscar Wilde",
  "Continuous improvement is better than delayed perfection. – Mark Twain",
  "The best way to predict the future is to create it. – Abraham Lincoln",
  "Success is not final, failure is not fatal: It is the courage to continue that counts. – Winston Churchill",
  "Your life does not get better by chance, it gets better by change. – Jim Rohn",
];

const healthWellnessQuotes = [
  "Take care of your body. It's the only place you have to live. – Jim Rohn",
  "A healthy outside starts from the inside. – Robert Urich",
  "The groundwork for all happiness is health. – Leigh Hunt",
  "Health is not valued until sickness comes. – Thomas Fuller",
  "The first wealth is health. – Ralph Waldo Emerson",
  "To keep the body in good health is a duty... otherwise we shall not be able to keep our mind strong and clear. – Buddha",
];

const careerGrowthQuotes = [
  "Success usually comes to those who are too busy to be looking for it. – Henry David Thoreau",
  "Choose a job you love, and you will never have to work a day in your life. – Confucius",
  "The future depends on what you do today. – Mahatma Gandhi",
  "Don't be afraid to give up the good to go for the great. – John D. Rockefeller",
  "Hardships often prepare ordinary people for an extraordinary destiny. – C.S. Lewis",
  "Opportunities don't happen, you create them. – Chris Grosser",
];

const relationshipsQuotes = [
  "Love is composed of a single soul inhabiting two bodies. – Aristotle",
  "The best thing to hold onto in life is each other. – Audrey Hepburn",
  "Trust is the glue of life. – Stephen Covey",
  "In the end, the love you take is equal to the love you make. – Paul McCartney",
  "A successful marriage requires falling in love many times, always with the same person. – Mignon McLaughlin",
  "The most important thing in the world is family and love. – John Wooden",
];

const resilienceQuotes = [
  "The greatest glory in living lies not in never falling, but in rising every time we fall. – Nelson Mandela",
  "Do not judge me by my success; judge me by how many times I fell and got back up again. – Nelson Mandela",
  "Fall seven times and stand up eight. – Japanese Proverb",
  "It does not matter how slowly you go as long as you do not stop. – Confucius",
  "The harder the battle, the sweeter the victory. – Les Brown",
  "Life is not about waiting for the storm to pass, but about learning to dance in the rain. – Unknown",
];
