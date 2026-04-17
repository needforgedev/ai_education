import 'dotenv/config';
import postgres from 'postgres';
import { drizzle } from 'drizzle-orm/postgres-js';
import { and, eq } from 'drizzle-orm';
import { cohorts, courses, modules, quizQuestions } from './index';

const sql = postgres(process.env.DATABASE_URL!, { max: 1 });
const db = drizzle(sql);

type LessonBlocks = string[];

type ModuleSeed = {
  orderIndex: number;
  title: string;
  objective: string;
  contentBlocks: LessonBlocks;
  quiz: { question: string; options: string[]; correctIndex: number }[];
};

const COURSE_TITLE = 'Introduction to AI';
const COURSE_ICON = '🤖';
const COURSE_DESCRIPTION =
  'A fun first look at Artificial Intelligence for young learners. Meet smart machines and see how they help us every day!';

const MODULE_SEEDS: ModuleSeed[] = [
  {
    orderIndex: 1,
    title: 'What is AI?',
    objective: 'Learn what Artificial Intelligence means in a fun, simple way.',
    contentBlocks: [
      '🤖 AI stands for Artificial Intelligence. That means making machines smart — like teaching a toy to think!',
      '🧠 Humans are smart because we can learn, remember, and solve problems. AI is when we teach computers to do the same things.',
      '📱 You already use AI every day! When Siri or Alexa answers your question, that is AI at work.',
      '🎮 Some video games have AI characters that think and react. They are not just following one rule — they learn from you.',
      '✨ Key idea: AI is about making machines learn, just like you learn in school!',
    ],
    quiz: [
      { question: 'What does AI stand for?', options: ['Amazing Idea', 'Artificial Intelligence', 'Apple iPhone', 'Animal Island'], correctIndex: 1 },
      { question: 'AI helps machines to…', options: ['Eat food', 'Think and learn', 'Sleep', 'Grow taller'], correctIndex: 1 },
      { question: 'Which of these is an example of AI?', options: ['A pencil', 'A wooden chair', 'Siri on a phone', 'A paper book'], correctIndex: 2 },
      { question: 'Can AI learn new things?', options: ['No, never', 'Yes, from data and examples', 'Only on Sundays', 'Only if it rains'], correctIndex: 1 },
      { question: 'AI is like a …', options: ['Smart machine', 'Hungry dog', 'Flying bird', 'Tall tree'], correctIndex: 0 },
      { question: 'Who makes AI smart?', options: ['The moon', 'People and data', 'Trees', 'Clouds'], correctIndex: 1 },
      { question: 'Alexa and Siri are examples of…', options: ['Cars', 'Voice assistants with AI', 'Birds', 'Pencils'], correctIndex: 1 },
      { question: 'Is AI a real thing today?', options: ['No, only in movies', 'Yes, it is all around us', 'Only in space', 'Only in books'], correctIndex: 1 },
      { question: 'AI can help with…', options: ['Answering questions', 'Growing plants by magic', 'Flying without wings', 'Being invisible'], correctIndex: 0 },
      { question: 'The main goal of AI is to make machines…', options: ['Sleep a lot', 'Act smart like humans', 'Break easily', 'Stay cold'], correctIndex: 1 },
    ],
  },
  {
    orderIndex: 2,
    title: 'How Do Machines Learn?',
    objective: 'Discover how computers learn from examples — just like you!',
    contentBlocks: [
      '🐶 How do you know what a dog looks like? Someone showed you lots of dogs, and you remembered!',
      '📸 Machines learn the same way. We show a computer thousands of pictures of dogs, and it learns to spot one.',
      '📚 This is called Machine Learning. Instead of writing rules, we give the computer examples.',
      '🎯 The more good examples we give, the better the machine gets. Practice makes perfect — for machines too!',
      '✨ Key idea: Machines learn from examples, not from strict rules.',
    ],
    quiz: [
      { question: 'How do machines learn?', options: ['From magic spells', 'From lots of examples', 'From sleeping', 'From eating'], correctIndex: 1 },
      { question: 'Machine Learning is when a computer…', options: ['Builds itself', 'Learns from data', 'Flies away', 'Shouts loudly'], correctIndex: 1 },
      { question: 'If a computer sees 1000 pictures of cats, it learns to…', options: ['Bake a cake', 'Recognize cats', 'Run fast', 'Grow fur'], correctIndex: 1 },
      { question: 'More good examples means…', options: ['The AI gets worse', 'The AI gets smarter', 'Nothing changes', 'The AI falls asleep'], correctIndex: 1 },
      { question: 'Humans and machines learn in similar ways by…', options: ['Guessing', 'Seeing examples', 'Closing eyes', 'Being loud'], correctIndex: 1 },
      { question: 'What is the short name for Machine Learning?', options: ['MM', 'ML', 'AI', 'LL'], correctIndex: 1 },
      { question: 'To teach AI, we need…', options: ['Silence', 'Data', 'Rain', 'A bicycle'], correctIndex: 1 },
      { question: 'If you show a computer only cats, can it recognize dogs?', options: ['Yes, perfectly', 'No, it needs to see dogs too', 'Only at night', 'Only if they bark'], correctIndex: 1 },
      { question: 'Practice helps AI become…', options: ['Slower', 'Smarter', 'Sleepier', 'Shorter'], correctIndex: 1 },
      { question: 'Learning from examples is called…', options: ['Snoring', 'Machine Learning', 'Shopping', 'Swimming'], correctIndex: 1 },
    ],
  },
  {
    orderIndex: 3,
    title: 'AI in Your Day',
    objective: 'Spot the AI around you — at home, at school, and on your screen.',
    contentBlocks: [
      '🏠 At home: Your parents may ask Alexa to play music. That is AI listening and understanding!',
      '📺 On YouTube: The app shows videos you might like. That is AI guessing what you enjoy!',
      '📷 On a phone camera: When your face is in focus, AI found your face in the picture!',
      '🚗 In cars: Some cars can tell when you get too close to another car. AI helps keep you safe.',
      '✨ Key idea: AI is already a part of many things you use every day.',
    ],
    quiz: [
      { question: 'Which of these uses AI?', options: ['A spoon', 'YouTube video suggestions', 'A notebook', 'A shoe'], correctIndex: 1 },
      { question: 'When Alexa plays a song, AI is…', options: ['Crying', 'Listening and understanding', 'Sleeping', 'Jumping'], correctIndex: 1 },
      { question: 'Your phone camera can find faces because of…', options: ['Glue', 'AI', 'Paint', 'Wind'], correctIndex: 1 },
      { question: 'AI in cars can help with…', options: ['Singing songs', 'Safety', 'Baking cookies', 'Growing flowers'], correctIndex: 1 },
      { question: 'When YouTube shows videos you like, AI is…', options: ['Dancing', 'Guessing what you like', 'Sleeping', 'Flying'], correctIndex: 1 },
      { question: 'Voice assistants understand…', options: ['Only songs', 'Your voice and questions', 'Only numbers', 'Only colors'], correctIndex: 1 },
      { question: 'AI is mostly found in…', options: ['Rocks', 'Technology we use', 'Trees', 'Clouds'], correctIndex: 1 },
      { question: 'Is AI helpful in our day?', options: ['No, never', 'Yes, it helps in many ways', 'Only on weekends', 'Only in summer'], correctIndex: 1 },
      { question: 'Which app uses AI to suggest shows?', options: ['Calculator', 'Netflix', 'Paint', 'Clock'], correctIndex: 1 },
      { question: 'AI in daily life is…', options: ['Very rare', 'Quite common', 'Never real', 'Only in books'], correctIndex: 1 },
    ],
  },
  {
    orderIndex: 4,
    title: 'Being Kind to AI (and People!)',
    objective: 'Learn why we should use AI carefully and be kind online.',
    contentBlocks: [
      '🌟 AI is a helper tool. Just like a pencil, it depends on how we use it.',
      '🤝 Always be kind and polite, even when talking to AI like Siri or Alexa. Good habits matter!',
      '❌ AI can sometimes get things wrong. If it gives a funny or silly answer, do not trust it blindly.',
      '🧒 Ask a grown-up if AI tells you something that feels strange or scary.',
      '✨ Key idea: AI is a tool. Use it kindly, and check its answers with trusted grown-ups.',
    ],
    quiz: [
      { question: 'AI is best used as a…', options: ['Toy that breaks', 'Helpful tool', 'Scary monster', 'Sneaky trick'], correctIndex: 1 },
      { question: 'Should you be polite to AI?', options: ['No, it does not care', 'Yes, good habits matter', 'Only on Mondays', 'Never'], correctIndex: 1 },
      { question: 'Can AI make mistakes?', options: ['No, never', 'Yes, sometimes', 'Only on holidays', 'Only in winter'], correctIndex: 1 },
      { question: 'If AI says something strange, you should…', options: ['Believe it right away', 'Ask a grown-up', 'Throw the device', 'Close your eyes'], correctIndex: 1 },
      { question: 'AI is like a…', options: ['Magic wizard', 'Tool we use', 'Wild animal', 'Tiny planet'], correctIndex: 1 },
      { question: 'Good online behavior means…', options: ['Being rude', 'Being kind', 'Shouting', 'Hiding'], correctIndex: 1 },
      { question: 'Should we trust every answer from AI?', options: ['Yes, always', 'No, check important ones', 'Only if it sings', 'Only if it is red'], correctIndex: 1 },
      { question: 'Grown-ups can help you when…', options: ['AI makes a mistake', 'It is sunny', 'You feel happy', 'You drink water'], correctIndex: 0 },
      { question: 'AI should be used…', options: ['Carelessly', 'Thoughtfully', 'Loudly', 'Secretly'], correctIndex: 1 },
      { question: 'Being kind online is…', options: ['Not important', 'Very important', 'Only for adults', 'Only on phones'], correctIndex: 1 },
    ],
  },
  {
    orderIndex: 5,
    title: 'What Can You Build with AI?',
    objective: 'Imagine fun and helpful things YOU could build with AI someday!',
    contentBlocks: [
      '🎨 AI can help make drawings and cartoons — you just describe what you want!',
      '📖 AI can help write stories. You give it an idea, and it writes a beginning for you.',
      '🎵 AI can make music — even songs that have never been heard before!',
      '🌍 AI helps scientists study the planet, animals, and space. You could do that someday too!',
      '✨ Key idea: With AI, you can dream big. One day, you might build something amazing.',
    ],
    quiz: [
      { question: 'AI can help you make…', options: ['A rock', 'Drawings and stories', 'A river', 'A tree'], correctIndex: 1 },
      { question: 'AI in music can…', options: ['Eat notes', 'Create new songs', 'Steal instruments', 'Break drums'], correctIndex: 1 },
      { question: 'Scientists use AI to study…', options: ['Clouds only', 'Many things like space and animals', 'Only socks', 'Only candy'], correctIndex: 1 },
      { question: 'If you have an idea for a story, AI can…', options: ['Laugh at it', 'Help you write it', 'Ignore you', 'Delete it'], correctIndex: 1 },
      { question: 'AI and creativity…', options: ['Do not mix', 'Work well together', 'Fight a lot', 'Are opposites'], correctIndex: 1 },
      { question: 'Can kids use AI tools?', options: ['Only adults can', 'Yes, with grown-up help', 'Only robots can', 'Never'], correctIndex: 1 },
      { question: 'AI art is made by…', options: ['Painting with paws', 'A computer following your idea', 'A bird with a brush', 'Magic dust'], correctIndex: 1 },
      { question: 'What can AI NOT do yet?', options: ['Think exactly like a human in every way', 'Help with pictures', 'Help with songs', 'Help with stories'], correctIndex: 0 },
      { question: 'A good way to use AI is to…', options: ['Build something helpful', 'Be mean', 'Hide it', 'Break it'], correctIndex: 0 },
      { question: 'With AI, the future is…', options: ['Boring', 'Exciting', 'Silent', 'Empty'], correctIndex: 1 },
    ],
  },
];

async function seedGrade34Course() {
  console.log('🌱 Starting seed for Grades 3-4 course...');

  const [cohort] = await db
    .select()
    .from(cohorts)
    .where(and(eq(cohorts.minGrade, 3), eq(cohorts.maxGrade, 4)))
    .limit(1);

  if (!cohort) {
    throw new Error(
      'Cohort for Grades 3-4 not found. Seed the cohorts table first (should already be done via Supabase Table Editor).'
    );
  }
  console.log(`✅ Found cohort: ${cohort.name} (${cohort.id})`);

  const existingCourse = await db
    .select()
    .from(courses)
    .where(and(eq(courses.cohortId, cohort.id), eq(courses.title, COURSE_TITLE)))
    .limit(1);

  if (existingCourse.length > 0) {
    console.log(
      `⚠️  Course "${COURSE_TITLE}" already exists for this cohort. Delete it from Supabase Table Editor if you want to re-seed.`
    );
    await sql.end();
    return;
  }

  const [insertedCourse] = await db
    .insert(courses)
    .values({
      cohortId: cohort.id,
      title: COURSE_TITLE,
      description: COURSE_DESCRIPTION,
      moduleCount: MODULE_SEEDS.length,
      icon: COURSE_ICON,
      orderIndex: 0,
      isPublished: true,
    })
    .returning();
  console.log(`✅ Inserted course: ${insertedCourse.title} (${insertedCourse.id})`);

  for (const m of MODULE_SEEDS) {
    const [insertedModule] = await db
      .insert(modules)
      .values({
        courseId: insertedCourse.id,
        title: m.title,
        objective: m.objective,
        contentBlocks: m.contentBlocks,
        orderIndex: m.orderIndex,
      })
      .returning();
    console.log(`  ✅ Module ${m.orderIndex}: ${insertedModule.title}`);

    const quizRows = m.quiz.map((q, idx) => ({
      moduleId: insertedModule.id,
      question: q.question,
      options: q.options,
      correctIndex: q.correctIndex,
      orderIndex: idx + 1,
    }));
    await db.insert(quizQuestions).values(quizRows);
    console.log(`     ↳ Inserted ${quizRows.length} quiz questions`);
  }

  console.log('🎉 Seed complete!');
  await sql.end();
}

seedGrade34Course().catch(async (err) => {
  console.error('❌ Seed failed:', err);
  await sql.end();
  process.exit(1);
});
