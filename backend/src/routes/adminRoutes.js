const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/auth');

const adminAuthController = require('../controllers/adminAuthController');
const usersController = require('../controllers/usersController');
const bloodRequestsController = require('../controllers/bloodRequestsController');
const educationRequestsController = require('../controllers/educationRequestsController');
const familyRequestsController = require('../controllers/familyRequestsController');
const dashboardController = require('../controllers/dashboardController');

router.post('/login', adminAuthController.login);
router.post('/logout', authMiddleware, adminAuthController.logout);
router.get('/profile', authMiddleware, adminAuthController.getProfile);

router.get('/users', authMiddleware, usersController.getAllUsers);
router.get('/users/:id', authMiddleware, usersController.getUserById);
router.put('/users/:id/approve', authMiddleware, usersController.approveUser);
router.put('/users/:id/reject', authMiddleware, usersController.rejectUser);
router.put('/users/:id/suspend', authMiddleware, usersController.suspendUser);

router.get('/blood-requests', authMiddleware, bloodRequestsController.getAllBloodRequests);
router.get('/blood-requests/:id', authMiddleware, bloodRequestsController.getBloodRequestById);
router.put('/blood-requests/:id/approve', authMiddleware, bloodRequestsController.approveBloodRequest);
router.put('/blood-requests/:id/reject', authMiddleware, bloodRequestsController.rejectBloodRequest);

router.get('/education-requests', authMiddleware, educationRequestsController.getAllEducationRequests);
router.get('/education-requests/:id', authMiddleware, educationRequestsController.getEducationRequestById);
router.put('/education-requests/:id/approve', authMiddleware, educationRequestsController.approveEducationRequest);
router.put('/education-requests/:id/reject', authMiddleware, educationRequestsController.rejectEducationRequest);

router.get('/family-requests', authMiddleware, familyRequestsController.getAllFamilyRequests);
router.get('/family-requests/:id', authMiddleware, familyRequestsController.getFamilyRequestById);
router.put('/family-requests/:id/approve', authMiddleware, familyRequestsController.approveFamilyRequest);
router.put('/family-requests/:id/reject', authMiddleware, familyRequestsController.rejectFamilyRequest);

router.get('/dashboard/stats', authMiddleware, dashboardController.getStats);
router.get('/dashboard/activity', authMiddleware, dashboardController.getActivity);
router.get('/dashboard/charts', authMiddleware, dashboardController.getChartData);

module.exports = router;
