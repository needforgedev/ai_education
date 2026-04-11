import 'app_state.dart';

class MockCohort {
  final String id;
  final String name;
  final int minGrade;
  final int maxGrade;

  const MockCohort({
    required this.id,
    required this.name,
    required this.minGrade,
    required this.maxGrade,
  });
}

class MockCourse {
  final String id;
  final String cohortId;
  final String title;
  final String description;
  final int moduleCount;
  final String icon;

  const MockCourse({
    required this.id,
    required this.cohortId,
    required this.title,
    required this.description,
    required this.moduleCount,
    required this.icon,
  });
}

class MockModule {
  final String id;
  final String courseId;
  final String title;
  final String objective;
  final int orderIndex;
  final List<String> lessonContent;

  const MockModule({
    required this.id,
    required this.courseId,
    required this.title,
    required this.objective,
    required this.orderIndex,
    required this.lessonContent,
  });
}

class MockQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  const MockQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

// --- Cohorts ---

const List<MockCohort> mockCohorts = [
  MockCohort(id: 'c1', name: 'Grades 3-4', minGrade: 3, maxGrade: 4),
  MockCohort(id: 'c2', name: 'Grades 5-6', minGrade: 5, maxGrade: 6),
  MockCohort(id: 'c3', name: 'Grades 7-8', minGrade: 7, maxGrade: 8),
  MockCohort(id: 'c4', name: 'Grades 9-10', minGrade: 9, maxGrade: 10),
  MockCohort(id: 'c5', name: 'Grades 11-12', minGrade: 11, maxGrade: 12),
];

MockCohort getCohortForGrade(int grade) {
  return mockCohorts.firstWhere(
    (c) => grade >= c.minGrade && grade <= c.maxGrade,
    orElse: () => mockCohorts.first,
  );
}

// --- Courses (for cohort c3: Grades 7-8 as sample) ---

const List<MockCourse> mockCourses = [
  MockCourse(
    id: 'course1',
    cohortId: 'c3',
    title: 'Introduction to AI',
    description: 'Learn what artificial intelligence is and how it works around you.',
    moduleCount: 10,
    icon: '🤖',
  ),
  MockCourse(
    id: 'course2',
    cohortId: 'c3',
    title: 'AI in Daily Life',
    description: 'Discover how AI powers things you use every day.',
    moduleCount: 10,
    icon: '🏠',
  ),
  MockCourse(
    id: 'course3',
    cohortId: 'c3',
    title: 'Prompting & Human-AI Interaction',
    description: 'Learn how to talk to AI systems effectively.',
    moduleCount: 10,
    icon: '💬',
  ),
  MockCourse(
    id: 'course4',
    cohortId: 'c3',
    title: 'Responsible AI & Safety',
    description: 'Understand the ethics and safety of AI systems.',
    moduleCount: 10,
    icon: '🛡️',
  ),
  MockCourse(
    id: 'course5',
    cohortId: 'c3',
    title: 'AI Projects & Problem Solving',
    description: 'Apply what you learned by building AI-powered solutions.',
    moduleCount: 10,
    icon: '🚀',
  ),
];

// --- Modules (for course1 as sample) ---

const List<MockModule> mockModules = [
  MockModule(
    id: 'm1',
    courseId: 'course1',
    title: 'What is Artificial Intelligence?',
    objective: 'Understand what AI means and where it came from.',
    orderIndex: 1,
    lessonContent: [
      'Artificial Intelligence (AI) is the ability of a computer or machine to think, learn, and make decisions — similar to how humans do.',
      'AI is not new! The idea started in the 1950s when scientists asked: "Can machines think?"',
      'Today, AI is everywhere — from voice assistants like Siri and Alexa, to recommendation systems on YouTube and Netflix.',
      'There are two broad types of AI:\n• Narrow AI — good at one specific task (like playing chess)\n• General AI — can do any intellectual task a human can (this doesn\'t exist yet!)',
      'Key takeaway: AI is about teaching machines to learn from data and make smart decisions.',
    ],
  ),
  MockModule(
    id: 'm2',
    courseId: 'course1',
    title: 'How Do Machines Learn?',
    objective: 'Learn the basics of how machines learn from data.',
    orderIndex: 2,
    lessonContent: [
      'Machine Learning (ML) is a way to teach computers by showing them examples instead of giving them step-by-step instructions.',
      'Imagine teaching a child to recognize cats. You don\'t explain every detail — you show them many pictures of cats, and they learn to spot one.',
      'That\'s how ML works: you feed the computer lots of data (examples), and it finds patterns on its own.',
      'The three main types of machine learning are:\n• Supervised Learning — learning with labeled examples\n• Unsupervised Learning — finding patterns in unlabeled data\n• Reinforcement Learning — learning by trial and error',
      'Key takeaway: Machines learn from data, not from being told every rule.',
    ],
  ),
  MockModule(
    id: 'm3',
    courseId: 'course1',
    title: 'Data: The Fuel of AI',
    objective: 'Understand why data is essential for AI systems.',
    orderIndex: 3,
    lessonContent: [
      'Without data, AI cannot learn. Data is like food for an AI system — the more quality data it gets, the smarter it becomes.',
      'Data can be many things: text, images, numbers, audio, or video.',
      'But not all data is good data. If you train an AI with biased or incorrect data, it will make biased or incorrect decisions.',
      'This is why data collection and cleaning is one of the most important steps in building an AI system.',
      'Key takeaway: Good AI starts with good data. Garbage in, garbage out!',
    ],
  ),
  MockModule(
    id: 'm4',
    courseId: 'course1',
    title: 'AI vs Humans: What\'s Different?',
    objective: 'Compare human intelligence with artificial intelligence.',
    orderIndex: 4,
    lessonContent: [
      'AI can process millions of data points in seconds — something no human can do. But humans have creativity, emotions, and common sense that AI lacks.',
      'AI is great at repetitive tasks, pattern recognition, and working with large amounts of data.',
      'Humans are better at understanding context, making ethical judgments, and being creative.',
      'The best results often come from humans and AI working together — each doing what they\'re best at.',
      'Key takeaway: AI and humans have different strengths. The future is collaboration, not competition.',
    ],
  ),
  MockModule(
    id: 'm5',
    courseId: 'course1',
    title: 'AI in Healthcare',
    objective: 'Explore how AI is transforming healthcare.',
    orderIndex: 5,
    lessonContent: [
      'AI is helping doctors diagnose diseases faster and more accurately. For example, AI can analyze X-rays and MRIs to spot problems humans might miss.',
      'Drug discovery, which used to take years, is being accelerated by AI that can simulate how molecules interact.',
      'AI chatbots can help patients get quick answers to basic health questions.',
      'Wearable devices use AI to monitor heart rate, sleep patterns, and alert users to potential health issues.',
      'Key takeaway: AI in healthcare saves lives by making diagnosis faster and treatments more personalized.',
    ],
  ),
  MockModule(
    id: 'm6',
    courseId: 'course1',
    title: 'AI in Education',
    objective: 'See how AI is changing the way we learn.',
    orderIndex: 6,
    lessonContent: [
      'AI-powered apps can personalize learning — adjusting difficulty based on how well you\'re doing.',
      'Language learning apps like Duolingo use AI to figure out which words you struggle with and test you on those more often.',
      'AI can help teachers by auto-grading quizzes and identifying students who need extra help.',
      'Virtual tutors powered by AI can answer questions 24/7, making learning accessible anytime.',
      'Key takeaway: AI makes education more personal, accessible, and efficient.',
    ],
  ),
  MockModule(
    id: 'm7',
    courseId: 'course1',
    title: 'AI in Entertainment',
    objective: 'Discover AI behind your favorite games and apps.',
    orderIndex: 7,
    lessonContent: [
      'Netflix and Spotify use AI to recommend shows and songs you might like based on what you\'ve watched or listened to before.',
      'Video games use AI to create smarter opponents that adapt to your playing style.',
      'AI can generate art, music, and even write stories — opening new creative possibilities.',
      'Social media feeds are ordered by AI algorithms that predict what content will keep you engaged.',
      'Key takeaway: AI shapes much of the entertainment you consume every day.',
    ],
  ),
  MockModule(
    id: 'm8',
    courseId: 'course1',
    title: 'How AI Makes Decisions',
    objective: 'Understand the basics of how AI arrives at answers.',
    orderIndex: 8,
    lessonContent: [
      'AI makes decisions using algorithms — step-by-step rules that process data and produce an output.',
      'A simple example: a spam filter looks at email keywords, sender reputation, and patterns to decide if an email is spam or not.',
      'More complex AI uses neural networks — structures inspired by the human brain with layers of connected nodes.',
      'The AI doesn\'t "understand" things like humans do. It finds statistical patterns and makes predictions based on probability.',
      'Key takeaway: AI decisions are based on patterns in data, not on true understanding.',
    ],
  ),
  MockModule(
    id: 'm9',
    courseId: 'course1',
    title: 'Bias and Fairness in AI',
    objective: 'Learn why AI can be unfair and how to fix it.',
    orderIndex: 9,
    lessonContent: [
      'AI learns from data created by humans — and humans have biases. So AI can inherit those biases.',
      'For example, if a hiring AI is trained on past data where mostly men were hired, it might unfairly favor male candidates.',
      'Bias in AI can lead to unfair outcomes in healthcare, criminal justice, lending, and more.',
      'To fight bias, we need diverse training data, regular audits, and diverse teams building AI systems.',
      'Key takeaway: AI is only as fair as the data and people behind it. Fairness requires active effort.',
    ],
  ),
  MockModule(
    id: 'm10',
    courseId: 'course1',
    title: 'The Future of AI',
    objective: 'Imagine what AI might look like in the coming years.',
    orderIndex: 10,
    lessonContent: [
      'AI is advancing rapidly. Self-driving cars, AI-powered scientific research, and smarter virtual assistants are just the beginning.',
      'Some experts believe we\'ll see AI that can perform any intellectual task a human can (Artificial General Intelligence) — but this is still far away.',
      'New jobs will be created around AI, while some existing jobs will change. Learning about AI now gives you a head start.',
      'The most important thing about AI\'s future is that humans get to shape it. The choices we make today determine what AI becomes tomorrow.',
      'Key takeaway: The future of AI is exciting — and you\'re learning about it at the perfect time!',
    ],
  ),
];

// --- Quiz Questions (sample for module 1) ---

List<List<MockQuestion>> mockQuizzes = [
  // Module 1 quiz
  [
    const MockQuestion(
      question: 'What does AI stand for?',
      options: ['Automatic Intelligence', 'Artificial Intelligence', 'Advanced Internet', 'Applied Integration'],
      correctIndex: 1,
    ),
    const MockQuestion(
      question: 'When did the idea of AI first start?',
      options: ['1920s', '1950s', '1980s', '2000s'],
      correctIndex: 1,
    ),
    const MockQuestion(
      question: 'Which of these is an example of Narrow AI?',
      options: ['A robot that can do everything', 'A chess-playing computer', 'A human brain', 'A calculator'],
      correctIndex: 1,
    ),
    const MockQuestion(
      question: 'Does General AI exist today?',
      options: ['Yes, it is common', 'Yes, but rare', 'No, not yet', 'It was invented last year'],
      correctIndex: 2,
    ),
    const MockQuestion(
      question: 'Which is an example of AI in daily life?',
      options: ['A light switch', 'A voice assistant like Siri', 'A paper notebook', 'A wooden table'],
      correctIndex: 1,
    ),
    const MockQuestion(
      question: 'AI helps machines to:',
      options: ['Only calculate numbers', 'Learn and make decisions', 'Replace all humans', 'Work without electricity'],
      correctIndex: 1,
    ),
    const MockQuestion(
      question: 'What is the main goal of AI?',
      options: ['To make machines think like humans', 'To destroy jobs', 'To make computers bigger', 'To replace the internet'],
      correctIndex: 0,
    ),
    const MockQuestion(
      question: 'Netflix recommendations are powered by:',
      options: ['Random guessing', 'AI algorithms', 'Human editors only', 'Magic'],
      correctIndex: 1,
    ),
    const MockQuestion(
      question: 'Which type of AI is good at one specific task?',
      options: ['General AI', 'Super AI', 'Narrow AI', 'Broad AI'],
      correctIndex: 2,
    ),
    const MockQuestion(
      question: 'AI learns from:',
      options: ['Textbooks only', 'Data and examples', 'Guessing', 'Nothing'],
      correctIndex: 1,
    ),
  ],
  // Modules 2-10: reuse a generic set for the walkthrough
  ...List.generate(9, (_) => [
    const MockQuestion(
      question: 'What is the primary way machines learn?',
      options: ['By being programmed with every rule', 'By learning from data', 'By copying humans exactly', 'By random chance'],
      correctIndex: 1,
    ),
    const MockQuestion(
      question: 'Which of these is NOT a type of machine learning?',
      options: ['Supervised Learning', 'Unsupervised Learning', 'Imaginary Learning', 'Reinforcement Learning'],
      correctIndex: 2,
    ),
    const MockQuestion(
      question: 'Good data is important because:',
      options: ['AI needs electricity', 'Bad data leads to bad results', 'Data is expensive', 'Computers like numbers'],
      correctIndex: 1,
    ),
    const MockQuestion(
      question: 'AI is best at:',
      options: ['Being creative', 'Processing large amounts of data', 'Having emotions', 'Making ethical choices'],
      correctIndex: 1,
    ),
    const MockQuestion(
      question: 'AI bias can come from:',
      options: ['Good weather', 'Biased training data', 'Fast computers', 'New software updates'],
      correctIndex: 1,
    ),
    const MockQuestion(
      question: 'AI in healthcare can help with:',
      options: ['Cooking food', 'Diagnosing diseases', 'Building houses', 'Driving buses'],
      correctIndex: 1,
    ),
    const MockQuestion(
      question: 'The future of AI depends on:',
      options: ['Only scientists', 'Choices made by all of us', 'Luck', 'Aliens'],
      correctIndex: 1,
    ),
    const MockQuestion(
      question: 'An algorithm is:',
      options: ['A type of food', 'Step-by-step instructions', 'A musical instrument', 'A planet'],
      correctIndex: 1,
    ),
    const MockQuestion(
      question: 'Neural networks are inspired by:',
      options: ['The internet', 'The human brain', 'A spider web', 'A library'],
      correctIndex: 1,
    ),
    const MockQuestion(
      question: 'AI and humans work best when they:',
      options: ['Compete against each other', 'Ignore each other', 'Collaborate together', 'Never interact'],
      correctIndex: 2,
    ),
  ]),
];

// --- Sample schools ---

const List<String> mockSchools = [
  'Sunrise Public School',
  'Delhi International Academy',
  'Greenfield High School',
  'St. Mary\'s Convent School',
  'Modern Era School',
  'Cambridge International School',
  'Oakridge Academy',
  'National Public School',
];

// --- Leaderboard ---

class LeaderboardEntry {
  final String studentName;
  final String school;
  final double score;
  final int rank;
  final String? courseId;

  const LeaderboardEntry({
    required this.studentName,
    required this.school,
    required this.score,
    required this.rank,
    this.courseId,
  });
}

List<LeaderboardEntry> mockLeaderboardEntries(String schoolName) {
  return [
    LeaderboardEntry(studentName: 'Riya Sharma', school: schoolName, score: 92, rank: 1),
    LeaderboardEntry(studentName: 'Aarav Patel', school: schoolName, score: 89, rank: 2),
    LeaderboardEntry(studentName: 'Meera Gupta', school: schoolName, score: 87, rank: 3),
    LeaderboardEntry(studentName: 'Omar Khan', school: schoolName, score: 84, rank: 4),
    LeaderboardEntry(studentName: 'Priya Nair', school: schoolName, score: 81, rank: 5),
    LeaderboardEntry(studentName: 'Arjun Singh', school: schoolName, score: 78, rank: 6),
    LeaderboardEntry(studentName: 'Zara Ali', school: schoolName, score: 75, rank: 7),
    LeaderboardEntry(studentName: 'Dev Mehta', school: schoolName, score: 72, rank: 8),
    LeaderboardEntry(studentName: 'Ananya Rao', school: schoolName, score: 70, rank: 9),
    LeaderboardEntry(studentName: 'Kabir Joshi', school: schoolName, score: 68, rank: 10),
  ];
}

// --- Community mock posts ---

List<CommunityPost> get mockCommunityPosts => [
  CommunityPost(
    id: 'post_1',
    author: 'Riya Sharma',
    title: 'Can someone explain training data?',
    body: 'I\'m on Module 3 and I don\'t fully understand what training data means. Can someone give a simple example?',
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    replies: [
      CommunityReply(
        author: 'Moderator Priya',
        body: 'Training data is the set of examples you give to an AI so it can learn patterns. Think of it like flashcards — the more you study, the better you get!',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isModeratorReply: true,
      ),
      CommunityReply(
        author: 'Omar Khan',
        body: 'So it\'s like showing a computer lots of pictures of cats so it learns what a cat looks like?',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ],
  ),
  CommunityPost(
    id: 'post_2',
    author: 'Aarav Patel',
    title: 'Module 5 quiz was tricky!',
    body: 'The healthcare module quiz had some tough questions. Did anyone else find question 7 confusing?',
    createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    replies: [
      CommunityReply(
        author: 'Meera Gupta',
        body: 'Yes! I had to retake it. Second time I scored 16/20 though.',
        createdAt: DateTime.now().subtract(const Duration(hours: 7)),
      ),
    ],
  ),
  CommunityPost(
    id: 'post_3',
    author: 'Moderator Priya',
    title: 'Welcome to the AI Basics community!',
    body: 'This is your space to ask doubts, discuss modules, and help each other learn. Be respectful and have fun learning about AI!',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    isModeratorPost: true,
    replies: [
      CommunityReply(
        author: 'Arjun Singh',
        body: 'Thanks! Excited to be here.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      CommunityReply(
        author: 'Zara Ali',
        body: 'This is going to be fun!',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ],
  ),
  CommunityPost(
    id: 'post_4',
    author: 'Dev Mehta',
    title: 'What\'s the difference between AI and Machine Learning?',
    body: 'Module 1 says AI is the big picture and ML is one part of it. But aren\'t they the same thing?',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    replies: [
      CommunityReply(
        author: 'Moderator Priya',
        body: 'Great question! AI is the broad goal of making smart machines. Machine Learning is one specific method to achieve AI — by letting machines learn from data instead of being explicitly programmed.',
        createdAt: DateTime.now().subtract(const Duration(hours: 20)),
        isModeratorReply: true,
      ),
    ],
  ),
  CommunityPost(
    id: 'post_5',
    author: 'Ananya Rao',
    title: 'Tips for the final submission?',
    body: 'I\'m almost done with all 10 modules. Any tips on what to write for the final project?',
    createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    replies: [],
  ),
];
