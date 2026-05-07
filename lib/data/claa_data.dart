// Christlike Attribute Activity content. Statements are reproduced verbatim from
// Preach My Gospel: A Guide to Sharing the Gospel of Jesus Christ (2023),
// Chapter 6: "Seek Christlike Attributes." © 2023 Intellectual Reserve, Inc.
// Used here for personal devotional self-reflection.

import '../models/attribute.dart';
import '../models/question.dart';

/// Scripture references on churchofjesuschrist.org follow this pattern:
///   /study/scriptures/<volume>/<book>/<chapter>?lang=eng&id=p<verse>#p<verse>
/// We store the path the church website expects and prepend the host at click time.
const String kChurchHost = 'https://www.churchofjesuschrist.org';

const List<Attribute> kAttributes = [
  Attribute(
    id: 'faith',
    name: 'Faith in Jesus Christ',
    shortName: 'Faith',
    icon: 'faith',
    color: 0xFF5B7FA8, // luminous sky blue
    description:
        'Faith in Jesus Christ is the first principle of the gospel. It is more '
        'than belief — it is a hope so anchored that it shapes how you live, '
        'choose, and endure. When you have faith in Christ, you trust that He '
        'suffered for your sins, that He hears you, and that His promises are '
        'sure even when the path is unclear.\n\n'
        'Faith leads to action. It moves us to repent, to keep covenants, and to '
        'extend ourselves toward others as the Savior would. The disciple\'s '
        'faith is not built on having all the answers, but on having met the '
        'Author of the answer.',
    questions: [
      Question(
        id: 'faith_1',
        text: 'I believe in Christ and accept Him as my Savior.',
        scriptures: [
          ScriptureRef(
            ref: '2 Nephi 25:29',
            path: '/study/scriptures/bofm/2-ne/25?lang=eng&id=p29#p29',
          ),
        ],
      ),
      Question(
        id: 'faith_2',
        text: 'I feel confident that God loves me.',
        scriptures: [
          ScriptureRef(
            ref: '1 Nephi 11:17',
            path: '/study/scriptures/bofm/1-ne/11?lang=eng&id=p17#p17',
          ),
        ],
      ),
      Question(
        id: 'faith_3',
        text: 'I trust the Savior enough to accept His will and do what He asks.',
        scriptures: [
          ScriptureRef(
            ref: '1 Nephi 3:7',
            path: '/study/scriptures/bofm/1-ne/3?lang=eng&id=p7#p7',
          ),
        ],
      ),
      Question(
        id: 'faith_4',
        text:
            'I believe that through the Atonement of Jesus Christ and the power of the Holy Ghost, '
            'I can be forgiven of my sins and sanctified as I repent.',
        scriptures: [
          ScriptureRef(
            ref: 'Enos 1:2–8',
            path: '/study/scriptures/bofm/enos/1?lang=eng&id=p2-p8#p2',
          ),
        ],
      ),
      Question(
        id: 'faith_5',
        text: 'I have faith that God hears and answers my prayers.',
        scriptures: [
          ScriptureRef(
            ref: 'Mosiah 27:14',
            path: '/study/scriptures/bofm/mosiah/27?lang=eng&id=p14#p14',
          ),
        ],
      ),
      Question(
        id: 'faith_6',
        text:
            'I think about the Savior during the day and remember what He has done for me.',
        scriptures: [
          ScriptureRef(
            ref: 'Doctrine and Covenants 20:77, 79',
            path:
                '/study/scriptures/dc-testament/dc/20?lang=eng&id=p77,p79#p77',
          ),
        ],
      ),
      Question(
        id: 'faith_7',
        text:
            'I have faith that God will bring about good things in my life and the lives of others as we devote ourselves to Him and His Son.',
        scriptures: [
          ScriptureRef(
            ref: 'Ether 12:12',
            path: '/study/scriptures/bofm/ether/12?lang=eng&id=p12#p12',
          ),
        ],
      ),
      Question(
        id: 'faith_8',
        text:
            'I know by the power of the Holy Ghost that the Book of Mormon is true.',
        scriptures: [
          ScriptureRef(
            ref: 'Moroni 10:3–5',
            path: '/study/scriptures/bofm/moro/10?lang=eng&id=p3-p5#p3',
          ),
        ],
      ),
      Question(
        id: 'faith_9',
        text: 'I have faith to accomplish what Christ wants me to do.',
        scriptures: [
          ScriptureRef(
            ref: 'Moroni 7:33',
            path: '/study/scriptures/bofm/moro/7?lang=eng&id=p33#p33',
          ),
        ],
      ),
    ],
  ),
  Attribute(
    id: 'hope',
    name: 'Hope',
    shortName: 'Hope',
    icon: 'hope',
    color: 0xFF7BA88E, // fresh sage — sunrise grass
    description:
        'Hope is the quiet confidence that what God has promised, He will fulfill. '
        'It is not optimism in good circumstances — it is steadfastness in any '
        'circumstance.\n\n'
        'The Apostle Paul calls hope an anchor of the soul. When you hope in '
        'Christ, you can face adversity without despair, wait through delay '
        'without bitterness, and look toward eternity with a settled heart. Hope '
        'is what allows faith to endure across long seasons.',
    questions: [
      Question(
        id: 'hope_1',
        text:
            'One of my greatest desires is to inherit eternal life in the celestial kingdom.',
        scriptures: [
          ScriptureRef(
            ref: 'Moroni 7:41',
            path: '/study/scriptures/bofm/moro/7?lang=eng&id=p41#p41',
          ),
        ],
      ),
      Question(
        id: 'hope_2',
        text: 'I am confident that I will have a happy and successful mission.',
        scriptures: [
          ScriptureRef(
            ref: 'Doctrine and Covenants 31:3–5',
            path:
                '/study/scriptures/dc-testament/dc/31?lang=eng&id=p3-p5#p3',
          ),
        ],
      ),
      Question(
        id: 'hope_3',
        text: 'I feel peaceful and optimistic about the future.',
        scriptures: [
          ScriptureRef(
            ref: 'Doctrine and Covenants 59:23',
            path:
                '/study/scriptures/dc-testament/dc/59?lang=eng&id=p23#p23',
          ),
        ],
      ),
      Question(
        id: 'hope_4',
        text: 'I believe that someday I will dwell with God and become like Him.',
        scriptures: [
          ScriptureRef(
            ref: 'Ether 12:4',
            path: '/study/scriptures/bofm/ether/12?lang=eng&id=p4#p4',
          ),
        ],
      ),
    ],
  ),
  Attribute(
    id: 'charity',
    name: 'Charity and Love',
    shortName: 'Charity',
    icon: 'charity',
    color: 0xFFC76B6B, // warm rose
    description:
        'Charity is the pure love of Christ. It is not a feeling we summon; it '
        'is a gift we ask for, given to those who follow the Savior with a '
        'willing heart.\n\n'
        'To love as Christ loves is to see others as He sees them — as souls '
        'of infinite worth, even when they wound or disappoint us. Charity '
        'moves us to forgive, to serve quietly, to think well of others, and '
        'to respond to a hard world with tenderness. The Lord said this is the '
        'greatest commandment because it summarizes all the rest.',
    questions: [
      Question(
        id: 'charity_1',
        text:
            'I feel a sincere desire for the eternal welfare and happiness of others.',
        scriptures: [
          ScriptureRef(
            ref: 'Mosiah 28:3',
            path: '/study/scriptures/bofm/mosiah/28?lang=eng&id=p3#p3',
          ),
        ],
      ),
      Question(
        id: 'charity_2',
        text: 'When I pray, I ask for charity—the pure love of Christ.',
        scriptures: [
          ScriptureRef(
            ref: 'Moroni 7:47–48',
            path: '/study/scriptures/bofm/moro/7?lang=eng&id=p47-p48#p47',
          ),
        ],
      ),
      Question(
        id: 'charity_3',
        text: 'I try to understand others\' feelings and see their point of view.',
        scriptures: [
          ScriptureRef(
            ref: 'Jude 1:22',
            path: '/study/scriptures/nt/jude/1?lang=eng&id=p22#p22',
          ),
        ],
      ),
      Question(
        id: 'charity_4',
        text: 'I forgive others who have offended or wronged me.',
        scriptures: [
          ScriptureRef(
            ref: 'Ephesians 4:32',
            path: '/study/scriptures/nt/eph/4?lang=eng&id=p32#p32',
          ),
        ],
      ),
      Question(
        id: 'charity_5',
        text:
            'I reach out in love to help those who are lonely, struggling, or discouraged.',
        scriptures: [
          ScriptureRef(
            ref: 'Mosiah 18:9',
            path: '/study/scriptures/bofm/mosiah/18?lang=eng&id=p9#p9',
          ),
        ],
      ),
      Question(
        id: 'charity_6',
        text:
            'When appropriate, I express my love and care for others by ministering through word and deed.',
        scriptures: [
          ScriptureRef(
            ref: 'Luke 7:12–15',
            path: '/study/scriptures/nt/luke/7?lang=eng&id=p12-p15#p12',
          ),
        ],
      ),
      Question(
        id: 'charity_7',
        text: 'I look for opportunities to serve others.',
        scriptures: [
          ScriptureRef(
            ref: 'Mosiah 2:17',
            path: '/study/scriptures/bofm/mosiah/2?lang=eng&id=p17#p17',
          ),
        ],
      ),
      Question(
        id: 'charity_8',
        text: 'I say positive things about others.',
        scriptures: [
          ScriptureRef(
            ref: 'Doctrine and Covenants 42:27',
            path:
                '/study/scriptures/dc-testament/dc/42?lang=eng&id=p27#p27',
          ),
        ],
      ),
      Question(
        id: 'charity_9',
        text:
            'I am kind and patient with others, even when they are hard to get along with.',
        scriptures: [
          ScriptureRef(
            ref: 'Moroni 7:45',
            path: '/study/scriptures/bofm/moro/7?lang=eng&id=p45#p45',
          ),
        ],
      ),
      Question(
        id: 'charity_10',
        text: 'I find joy in others\' achievements.',
        scriptures: [
          ScriptureRef(
            ref: 'Alma 17:2–4',
            path: '/study/scriptures/bofm/alma/17?lang=eng&id=p2-p4#p2',
          ),
        ],
      ),
    ],
  ),
  Attribute(
    id: 'virtue',
    name: 'Virtue',
    shortName: 'Virtue',
    icon: 'virtue',
    color: 0xFF8161A8, // soft warm purple
    description:
        'Virtue is purity of thought, word, and deed. It begins in the heart — '
        'in what you choose to dwell on, what you turn away from, and what you '
        'welcome in.\n\n'
        'To be virtuous is to be at peace with the Spirit. It does not mean '
        'being without weakness, but rather repenting honestly when you fall '
        'and asking the Savior to make you whole again. As you walk in virtue, '
        'your confidence before God grows, and the Holy Ghost becomes a '
        'constant friend.',
    questions: [
      Question(
        id: 'virtue_1',
        text: 'I am clean and pure in heart.',
        scriptures: [
          ScriptureRef(
            ref: 'Psalm 24:3–4',
            path: '/study/scriptures/ot/ps/24?lang=eng&id=p3-p4#p3',
          ),
        ],
      ),
      Question(
        id: 'virtue_2',
        text: 'I desire to do good.',
        scriptures: [
          ScriptureRef(
            ref: 'Mosiah 5:2',
            path: '/study/scriptures/bofm/mosiah/5?lang=eng&id=p2#p2',
          ),
        ],
      ),
      Question(
        id: 'virtue_3',
        text:
            'I focus on righteous, uplifting thoughts and put unwholesome thoughts out of my mind.',
        scriptures: [
          ScriptureRef(
            ref: 'Doctrine and Covenants 121:45',
            path:
                '/study/scriptures/dc-testament/dc/121?lang=eng&id=p45#p45',
          ),
        ],
      ),
      Question(
        id: 'virtue_4',
        text: 'I repent of my sins and strive to overcome my weaknesses.',
        scriptures: [
          ScriptureRef(
            ref: 'Doctrine and Covenants 49:26–28',
            path:
                '/study/scriptures/dc-testament/dc/49?lang=eng&id=p26-p28#p26',
          ),
          ScriptureRef(
            ref: 'Ether 12:27',
            path: '/study/scriptures/bofm/ether/12?lang=eng&id=p27#p27',
          ),
        ],
      ),
      Question(
        id: 'virtue_5',
        text: 'I feel the influence of the Holy Ghost in my life.',
        scriptures: [
          ScriptureRef(
            ref: 'Doctrine and Covenants 11:12–13',
            path:
                '/study/scriptures/dc-testament/dc/11?lang=eng&id=p12-p13#p12',
          ),
        ],
      ),
    ],
  ),
  Attribute(
    id: 'integrity',
    name: 'Integrity',
    shortName: 'Integrity',
    icon: 'integrity',
    color: 0xFF5B8067, // forest green
    description:
        'Integrity is being whole — your inner life and your outer life made '
        'of the same cloth. A person of integrity tells the truth even when '
        'it costs them, keeps their word even when no one is watching, and '
        'acts the same in private as in public.\n\n'
        'The Lord trusted His servants because they could be trusted. When '
        'you walk in integrity, you become a person whose yes means yes — to '
        'God, to those you love, and to yourself.',
    questions: [
      Question(
        id: 'integrity_1',
        text: 'I am true to God at all times.',
        scriptures: [
          ScriptureRef(
            ref: 'Mosiah 18:9',
            path: '/study/scriptures/bofm/mosiah/18?lang=eng&id=p9#p9',
          ),
        ],
      ),
      Question(
        id: 'integrity_2',
        text:
            'I do not lower my standards or behavior so I can impress or be accepted by others.',
        scriptures: [
          ScriptureRef(
            ref: '1 Nephi 8:24–28',
            path: '/study/scriptures/bofm/1-ne/8?lang=eng&id=p24-p28#p24',
          ),
        ],
      ),
      Question(
        id: 'integrity_3',
        text: 'I am honest with God, myself, my leaders, and others.',
        scriptures: [
          ScriptureRef(
            ref: 'Doctrine and Covenants 51:9',
            path:
                '/study/scriptures/dc-testament/dc/51?lang=eng&id=p9#p9',
          ),
        ],
      ),
      Question(
        id: 'integrity_4',
        text: 'I am dependable.',
        scriptures: [
          ScriptureRef(
            ref: 'Alma 53:20',
            path: '/study/scriptures/bofm/alma/53?lang=eng&id=p20#p20',
          ),
        ],
      ),
    ],
  ),
  Attribute(
    id: 'knowledge',
    name: 'Knowledge',
    shortName: 'Knowledge',
    icon: 'knowledge',
    color: 0xFFD4A65C, // warm amber gold
    description:
        'Knowledge of spiritual things comes by both study and faith. The Lord '
        'invites us to seek understanding of His doctrine — through the '
        'scriptures, through prayer, through pondering, and through obedience.\n\n'
        'True knowledge is not just information; it is light that comes line '
        'upon line as we are ready to receive it. The Spirit teaches the willing '
        'student, and what we come to know transforms how we live.',
    questions: [
      Question(
        id: 'knowledge_1',
        text:
            'I feel confident in my understanding of gospel doctrine and principles.',
        scriptures: [
          ScriptureRef(
            ref: 'Alma 17:2–3',
            path: '/study/scriptures/bofm/alma/17?lang=eng&id=p2-p3#p2',
          ),
        ],
      ),
      Question(
        id: 'knowledge_2',
        text: 'I study the scriptures daily.',
        scriptures: [
          ScriptureRef(
            ref: '2 Timothy 3:16–17',
            path:
                '/study/scriptures/nt/2-tim/3?lang=eng&id=p16-p17#p16',
          ),
        ],
      ),
      Question(
        id: 'knowledge_3',
        text: 'I seek to understand the truth and find answers to my questions.',
        scriptures: [
          ScriptureRef(
            ref: 'Doctrine and Covenants 6:7',
            path:
                '/study/scriptures/dc-testament/dc/6?lang=eng&id=p7#p7',
          ),
        ],
      ),
      Question(
        id: 'knowledge_4',
        text: 'I seek knowledge and guidance through the Spirit.',
        scriptures: [
          ScriptureRef(
            ref: '1 Nephi 4:6',
            path: '/study/scriptures/bofm/1-ne/4?lang=eng&id=p6#p6',
          ),
        ],
      ),
      Question(
        id: 'knowledge_5',
        text: 'I cherish the doctrine and principles of the gospel.',
        scriptures: [
          ScriptureRef(
            ref: '2 Nephi 4:15',
            path: '/study/scriptures/bofm/2-ne/4?lang=eng&id=p15#p15',
          ),
        ],
      ),
    ],
  ),
  Attribute(
    id: 'patience',
    name: 'Patience',
    shortName: 'Patience',
    icon: 'patience',
    color: 0xFF6B9E94, // sage teal — quiet water
    description:
        'Patience is the willingness to endure delay, opposition, and '
        'difficulty without losing your bearings. It is the trust that God\'s '
        'timing is right even when our hearts are restless.\n\n'
        'The Savior was patient with His disciples, with the multitudes, with '
        'you and me. To grow in patience is to grow in the kind of steady love '
        'that does not give up — on others, on yourself, or on the long work '
        'of becoming.',
    questions: [
      Question(
        id: 'patience_1',
        text:
            'I wait patiently for the blessings and promises of the Lord to be fulfilled.',
        scriptures: [
          ScriptureRef(
            ref: '2 Nephi 10:17',
            path: '/study/scriptures/bofm/2-ne/10?lang=eng&id=p17#p17',
          ),
        ],
      ),
      Question(
        id: 'patience_2',
        text: 'I am able to wait for things without getting upset or frustrated.',
        scriptures: [
          ScriptureRef(
            ref: 'Romans 8:25',
            path: '/study/scriptures/nt/rom/8?lang=eng&id=p25#p25',
          ),
        ],
      ),
      Question(
        id: 'patience_3',
        text: 'I am patient with the challenges of being a missionary.',
        scriptures: [
          ScriptureRef(
            ref: 'Alma 17:11',
            path: '/study/scriptures/bofm/alma/17?lang=eng&id=p11#p11',
          ),
        ],
      ),
      Question(
        id: 'patience_4',
        text: 'I am patient with others.',
        scriptures: [
          ScriptureRef(
            ref: 'Romans 15:1',
            path: '/study/scriptures/nt/rom/15?lang=eng&id=p1#p1',
          ),
        ],
      ),
      Question(
        id: 'patience_5',
        text:
            'I am patient with myself and rely on the Lord as I work to overcome my weaknesses.',
        scriptures: [
          ScriptureRef(
            ref: 'Ether 12:27',
            path: '/study/scriptures/bofm/ether/12?lang=eng&id=p27#p27',
          ),
        ],
      ),
      Question(
        id: 'patience_6',
        text: 'I face adversity with patience and faith.',
        scriptures: [
          ScriptureRef(
            ref: 'Alma 34:40–41',
            path:
                '/study/scriptures/bofm/alma/34?lang=eng&id=p40-p41#p40',
          ),
        ],
      ),
    ],
  ),
  Attribute(
    id: 'humility',
    name: 'Humility',
    shortName: 'Humility',
    icon: 'humility',
    color: 0xFFA88B6F, // warm taupe — earthen humility
    description:
        'Humility is not thinking less of yourself; it is thinking of yourself '
        'less. It is the honest recognition that every gift you have comes '
        'from God, and that you cannot make it home without His help.\n\n'
        'The humble are teachable. They give credit, ask for guidance, and '
        'submit their will to the Father\'s — not because they are weak, but '
        'because they trust His love. As you grow in humility, the Lord can '
        'lead you where pride could never take you.',
    questions: [
      Question(
        id: 'humility_1',
        text: 'I am meek and lowly in heart.',
        scriptures: [
          ScriptureRef(
            ref: 'Matthew 11:29',
            path: '/study/scriptures/nt/matt/11?lang=eng&id=p29#p29',
          ),
        ],
      ),
      Question(
        id: 'humility_2',
        text: 'I rely on God for help.',
        scriptures: [
          ScriptureRef(
            ref: 'Alma 26:12',
            path: '/study/scriptures/bofm/alma/26?lang=eng&id=p12#p12',
          ),
        ],
      ),
      Question(
        id: 'humility_3',
        text: 'I am grateful for the blessings I have received from God.',
        scriptures: [
          ScriptureRef(
            ref: 'Alma 7:23',
            path: '/study/scriptures/bofm/alma/7?lang=eng&id=p23#p23',
          ),
        ],
      ),
      Question(
        id: 'humility_4',
        text: 'My prayers are earnest and sincere.',
        scriptures: [
          ScriptureRef(
            ref: 'Enos 1:4',
            path: '/study/scriptures/bofm/enos/1?lang=eng&id=p4#p4',
          ),
        ],
      ),
      Question(
        id: 'humility_5',
        text: 'I appreciate direction from my leaders or teachers.',
        scriptures: [
          ScriptureRef(
            ref: '2 Nephi 9:28–29',
            path: '/study/scriptures/bofm/2-ne/9?lang=eng&id=p28-p29#p28',
          ),
        ],
      ),
      Question(
        id: 'humility_6',
        text: 'I strive to be submissive to God\'s will.',
        scriptures: [
          ScriptureRef(
            ref: 'Mosiah 24:15',
            path: '/study/scriptures/bofm/mosiah/24?lang=eng&id=p15#p15',
          ),
        ],
      ),
    ],
  ),
  Attribute(
    id: 'diligence',
    name: 'Diligence',
    shortName: 'Diligence',
    icon: 'diligence',
    color: 0xFFD17A50, // terracotta — steady hand at work
    description:
        'Diligence is steady, faithful effort over time. It is the disciple '
        'who keeps showing up — to prayer, to scripture study, to service — '
        'when no one is watching and no immediate reward is in sight.\n\n'
        'The Lord blesses those who are anxiously engaged in a good cause. '
        'Diligence is not anxious striving; it is the unhurried, persistent '
        'work of someone who believes that small daily acts add up to a life '
        'consecrated to Christ.',
    questions: [
      Question(
        id: 'diligence_1',
        text: 'I work effectively, even when I\'m not under close supervision.',
        scriptures: [
          ScriptureRef(
            ref: 'Doctrine and Covenants 58:26–27',
            path:
                '/study/scriptures/dc-testament/dc/58?lang=eng&id=p26-p27#p26',
          ),
        ],
      ),
      Question(
        id: 'diligence_2',
        text: 'I focus my efforts on the most important things.',
        scriptures: [
          ScriptureRef(
            ref: 'Matthew 23:23',
            path: '/study/scriptures/nt/matt/23?lang=eng&id=p23#p23',
          ),
        ],
      ),
      Question(
        id: 'diligence_3',
        text: 'I have a personal prayer at least twice a day.',
        scriptures: [
          ScriptureRef(
            ref: 'Alma 34:17–27',
            path:
                '/study/scriptures/bofm/alma/34?lang=eng&id=p17-p27#p17',
          ),
        ],
      ),
      Question(
        id: 'diligence_4',
        text: 'I focus my thoughts on my calling as a missionary.',
        scriptures: [
          ScriptureRef(
            ref: 'Doctrine and Covenants 4:2, 5',
            path:
                '/study/scriptures/dc-testament/dc/4?lang=eng&id=p2,p5#p2',
          ),
        ],
      ),
      Question(
        id: 'diligence_5',
        text: 'I set goals and plan regularly.',
        scriptures: [
          ScriptureRef(
            ref: 'Doctrine and Covenants 88:119',
            path:
                '/study/scriptures/dc-testament/dc/88?lang=eng&id=p119#p119',
          ),
        ],
      ),
      Question(
        id: 'diligence_6',
        text: 'I work hard until the job is completed.',
        scriptures: [
          ScriptureRef(
            ref: 'Doctrine and Covenants 10:4',
            path:
                '/study/scriptures/dc-testament/dc/10?lang=eng&id=p4#p4',
          ),
        ],
      ),
      Question(
        id: 'diligence_7',
        text: 'I find joy and satisfaction in my work.',
        scriptures: [
          ScriptureRef(
            ref: 'Alma 36:24–25',
            path: '/study/scriptures/bofm/alma/36?lang=eng&id=p24-p25#p24',
          ),
        ],
      ),
    ],
  ),
  Attribute(
    id: 'obedience',
    name: 'Obedience',
    shortName: 'Obedience',
    icon: 'obedience',
    color: 0xFF7A9555, // olive green — covenant land
    description:
        'Obedience is the first law of heaven. It is how love for the Savior '
        'becomes visible — by the way we keep His commandments and follow the '
        'counsel of those He has called.\n\n'
        'Obedience is not blind submission; it is the response of a trusting '
        'heart to a wise Father. Each act of obedience invites greater light '
        'into your life and prepares you to receive what God most wants to '
        'give you. As the Savior said, "If ye love me, keep my commandments."',
    questions: [
      Question(
        id: 'obedience_1',
        text:
            'When I pray, I ask for strength to resist temptation and to do what is right.',
        scriptures: [
          ScriptureRef(
            ref: '3 Nephi 18:15',
            path: '/study/scriptures/bofm/3-ne/18?lang=eng&id=p15#p15',
          ),
        ],
      ),
      Question(
        id: 'obedience_2',
        text: 'I am worthy to have a temple recommend.',
        scriptures: [
          ScriptureRef(
            ref: 'Doctrine and Covenants 97:8',
            path:
                '/study/scriptures/dc-testament/dc/97?lang=eng&id=p8#p8',
          ),
        ],
      ),
      Question(
        id: 'obedience_3',
        text:
            'I willingly obey the mission rules and follow the counsel of my leaders.',
        scriptures: [
          ScriptureRef(
            ref: 'Hebrews 13:17',
            path: '/study/scriptures/nt/heb/13?lang=eng&id=p17#p17',
          ),
        ],
      ),
      Question(
        id: 'obedience_4',
        text:
            'I strive to live in accordance with the laws and principles of the gospel.',
        scriptures: [
          ScriptureRef(
            ref: 'Doctrine and Covenants 41:5',
            path:
                '/study/scriptures/dc-testament/dc/41?lang=eng&id=p5#p5',
          ),
        ],
      ),
    ],
  ),
];

/// 1 = Never, 2 = Sometimes, 3 = Often, 4 = Usually, 5 = Always
const List<String> kRatingLabels = [
  'Never',
  'Sometimes',
  'Often',
  'Usually',
  'Always',
];
