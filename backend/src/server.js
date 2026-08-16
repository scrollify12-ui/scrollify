require('dotenv').config();
const express = require('express');
const cors = require('cors');
const admin = require('firebase-admin');
const { PrismaClient } = require('@prisma/client');
const { Pool } = require('pg');
const { PrismaPg } = require('@prisma/adapter-pg');

// Initialize Firebase Admin for token verification
admin.initializeApp({
  projectId: 'scrollz-7087d'
});

const pool = new Pool({ connectionString: process.env.DATABASE_URL });
const adapter = new PrismaPg(pool);
const prisma = new PrismaClient({ adapter });

const app = express();

app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok', message: 'Backend is running' });
});

const { getAuth } = require('firebase-admin/auth');

// Middleware to verify Firebase ID token
const authenticate = async (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Unauthorized: Missing or invalid Bearer token' });
  }

  const token = authHeader.split('Bearer ')[1];
  try {
    const decodedToken = await getAuth().verifyIdToken(token);
    req.user = decodedToken;
    next();
  } catch (error) {
    console.error('Error verifying Firebase ID token:', error);
    return res.status(401).json({ error: 'Unauthorized: Invalid token' });
  }
};

// Auth Sync API
app.post('/api/auth/sync', authenticate, async (req, res) => {
  const firebaseUid = req.user.uid;
  const email = req.user.email || req.body.email;

  try {
    // Check if user exists
    let user = await prisma.user.findUnique({
      where: { firebaseUid }
    });

    if (user) {
      // User already exists, update lastLogin
      user = await prisma.user.update({
        where: { firebaseUid },
        data: { lastLogin: new Date() }
      });
      return res.status(200).json(user);
    } else {
      // User does not exist, create new user
      const { fullName, username, profilePhoto, instagramHandle } = req.body;

      // Validate required fields for creation
      if (!fullName || !username || !email) {
        return res.status(400).json({ error: 'Missing required fields: fullName, username, or email' });
      }

      // Username Validation
      const existingUsername = await prisma.user.findUnique({
        where: { username }
      });

      if (existingUsername) {
        return res.status(409).json({ error: 'Username is already taken' });
      }

      user = await prisma.user.create({
        data: {
          firebaseUid,
          email,
          fullName,
          username,
          profilePhoto: profilePhoto || null,
          instagramHandle: instagramHandle || null,
          lastLogin: new Date()
        }
      });
      return res.status(201).json(user);
    }
  } catch (error) {
    console.error('Error in /api/auth/sync:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
});

app.get('/api/users/me', authenticate, async (req, res) => {
  try {
    const firebaseUid = req.user.uid;
    const user = await prisma.user.findUnique({
      where: { firebaseUid }
    });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    return res.status(200).json(user);
  } catch (error) {
    console.error('Error fetching current user:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
});

app.get('/api/users/check-username', authenticate, async (req, res) => {
  const { username } = req.query;
  console.log(`[Username Check] Received request for username: "${username}"`);
  
  if (!username) {
    console.log(`[Username Check] Request failed: Username is required`);
    return res.status(400).json({ error: 'Username is required' });
  }

  try {
    const user = await prisma.user.findUnique({ where: { username: username.toLowerCase() } });
    
    if (user) {
      console.log(`[Username Check] Result: Username "${username}" already exists in database.`);
      console.log(`[Username Check] Response: { available: false }`);
      return res.status(200).json({ available: false });
    }
    
    console.log(`[Username Check] Result: Username "${username}" is available.`);
    console.log(`[Username Check] Response: { available: true }`);
    return res.status(200).json({ available: true });
  } catch (error) {
    console.error(`[Username Check] Error checking username "${username}":`, error);
    return res.status(500).json({ error: 'Internal server error' });
  }
});

// Get User Profile API
app.get('/api/users/profile', authenticate, async (req, res) => {
  const firebaseUid = req.user.uid;
  console.log('\n========== PROFILE REQUEST ==========');
  console.log(`Firebase UID: ${firebaseUid}`);
  console.log(`Database Query: SELECT * FROM "User" WHERE firebaseUid = '${firebaseUid}';`);

  try {
    const user = await prisma.user.findUnique({
      where: { firebaseUid }
    });
    
    console.log(`User Found: ${user ? 'Yes' : 'No'}`);
    console.log(`Response JSON: ${user ? JSON.stringify(user) : '{"error":"User not found"}'}`);
    console.log(`HTTP Status: ${user ? 200 : 404}`);
    console.log('====================================\n');
    
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    return res.status(200).json(user);
  } catch (error) {
    console.log(`HTTP Status: 500`);
    console.error('Real Error Exception:', error);
    console.log('====================================\n');
    return res.status(500).json({ error: 'Internal server error', details: error.message });
  }
});
// Suggestions API
app.get('/api/users/suggestions', authenticate, async (req, res) => {
  const firebaseUid = req.user.uid;
  try {
    const currentUser = await prisma.user.findUnique({
      where: { firebaseUid }
    });

    if (!currentUser) return res.status(404).json({ error: 'Current user not found' });

    // Get popular users (by points/streak)
    const users = await prisma.user.findMany({
      where: {
        id: {
          not: currentUser.id // Exclude self
        }
      },
      orderBy: [
        { points: 'desc' },
        { streak: 'desc' }
      ],
      take: 4,
      select: {
        id: true,
        fullName: true,
        username: true,
        profilePhoto: true,
        points: true,
        streak: true
      }
    });

    // Check friendship status for each user
    const userIds = users.map(u => u.id);
    const friendships = await prisma.friendship.findMany({
      where: {
        OR: [
          { senderId: currentUser.id, receiverId: { in: userIds } },
          { receiverId: currentUser.id, senderId: { in: userIds } }
        ]
      }
    });

    const results = users.map(user => {
      let friendStatus = 'none';
      const friendship = friendships.find(
        f => (f.senderId === currentUser.id && f.receiverId === user.id) ||
             (f.receiverId === currentUser.id && f.senderId === user.id)
      );

      if (friendship) {
        if (friendship.status === 'accepted') {
          friendStatus = 'friends';
        } else if (friendship.status === 'pending') {
          if (friendship.senderId === currentUser.id) {
            friendStatus = 'request_sent';
          } else {
            friendStatus = 'requested';
          }
        }
      }

      return {
        ...user,
        friendStatus
      };
    });

    return res.status(200).json(results);
  } catch (error) {
    console.error('Error fetching suggestions:', error);
    return res.status(500).json({ error: 'Internal server error', details: error.message });
  }
});

// Search API
app.get('/api/users/search', authenticate, async (req, res) => {
  const { q } = req.query;
  const firebaseUid = req.user.uid;
  
  if (!q || q.length < 2) {
    return res.status(200).json([]);
  }

  try {
    const currentUser = await prisma.user.findUnique({
      where: { firebaseUid }
    });

    if (!currentUser) return res.status(404).json({ error: 'Current user not found' });

    // Search users by username or fullName (case-insensitive)
    const users = await prisma.user.findMany({
      where: {
        OR: [
          { username: { contains: q, mode: 'insensitive' } },
          { fullName: { contains: q, mode: 'insensitive' } },
        ],
        id: {
          not: currentUser.id // Exclude self
        }
      },
      take: 30,
      select: {
        id: true,
        fullName: true,
        username: true,
        profilePhoto: true,
        points: true,
        streak: true
      }
    });

    // Check friendship status for each user
    const userIds = users.map(u => u.id);
    const friendships = await prisma.friendship.findMany({
      where: {
        OR: [
          { senderId: currentUser.id, receiverId: { in: userIds } },
          { receiverId: currentUser.id, senderId: { in: userIds } }
        ]
      }
    });

    const results = users.map(user => {
      let friendStatus = 'none';
      const friendship = friendships.find(
        f => (f.senderId === currentUser.id && f.receiverId === user.id) ||
             (f.receiverId === currentUser.id && f.senderId === user.id)
      );

      if (friendship) {
        if (friendship.status === 'accepted') {
          friendStatus = 'friends';
        } else if (friendship.status === 'pending') {
          if (friendship.senderId === currentUser.id) {
            friendStatus = 'request_sent';
          } else {
            friendStatus = 'requested';
          }
        }
      }

      return {
        ...user,
        friendStatus
      };
    });

    // Generate smart mock suggestions if search results are sparse
    const qLower = q.toLowerCase();
    const mockPool = [
      { id: 'mock-1', username: `${qLower}_official`, fullName: `${q.charAt(0).toUpperCase() + q.slice(1)} Official`, profilePhoto: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150', points: 120, streak: 5, friendStatus: 'none' },
      { id: 'mock-2', username: `${qLower}_kumar`, fullName: `${q.charAt(0).toUpperCase() + q.slice(1)} Kumar`, profilePhoto: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150', points: 340, streak: 12, friendStatus: 'none' },
      { id: 'mock-3', username: `real_${qLower}`, fullName: `Real ${q.charAt(0).toUpperCase() + q.slice(1)}`, profilePhoto: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150', points: 890, streak: 21, friendStatus: 'none' },
      { id: 'mock-4', username: `${qLower}_styles`, fullName: `${q.charAt(0).toUpperCase() + q.slice(1)} Styles`, profilePhoto: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150', points: 450, streak: 7, friendStatus: 'none' },
      { id: 'mock-5', username: `${qLower}_star`, fullName: `${q.charAt(0).toUpperCase() + q.slice(1)} Star`, profilePhoto: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150', points: 610, streak: 15, friendStatus: 'none' },
    ];

    const finalResults = [...results];
    for (const mock of mockPool) {
      if (finalResults.length >= 10) break;
      if (!finalResults.some(r => r.username.toLowerCase() === mock.username.toLowerCase())) {
        finalResults.push(mock);
      }
    }

    return res.status(200).json(finalResults);
  } catch (error) {
    console.error('Error searching users:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
});

// Send Friend Request
app.post('/api/friends/request', authenticate, async (req, res) => {
  const { targetUserId } = req.body;
  const firebaseUid = req.user.uid;

  try {
    const currentUser = await prisma.user.findUnique({ where: { firebaseUid } });
    if (!currentUser) return res.status(404).json({ error: 'Current user not found' });
    if (currentUser.id === targetUserId) return res.status(400).json({ error: 'Cannot add yourself' });

    // Check existing friendship
    const existing = await prisma.friendship.findFirst({
      where: {
        OR: [
          { senderId: currentUser.id, receiverId: targetUserId },
          { receiverId: currentUser.id, senderId: targetUserId }
        ]
      }
    });

    if (existing) {
      return res.status(400).json({ error: 'Friendship or request already exists' });
    }

    const friendship = await prisma.friendship.create({
      data: {
        senderId: currentUser.id,
        receiverId: targetUserId,
        status: 'pending'
      }
    });

    return res.status(200).json({ success: true, status: 'request_sent' });
  } catch (error) {
    console.error('Error sending friend request:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
});
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
  console.log('Server restarted to load updated Prisma client');
  console.log('Force restart after generation');
});
