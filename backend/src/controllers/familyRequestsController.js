const pool = require('../config/database');

exports.getAllFamilyRequests = async (req, res) => {
  try {
    const { status } = req.query;

    let query = `
      SELECT fr.*, u.full_name as user_name, u.email as user_email
      FROM family_requests fr
      LEFT JOIN users u ON fr.user_id = u.id
      ORDER BY fr.created_at DESC
    `;
    let params = [];

    if (status) {
      query = `
        SELECT fr.*, u.full_name as user_name, u.email as user_email
        FROM family_requests fr
        LEFT JOIN users u ON fr.user_id = u.id
        WHERE fr.status = $1
        ORDER BY fr.created_at DESC
      `;
      params = [status];
    }

    const result = await pool.query(query, params);

    res.json({
      success: true,
      data: result.rows,
    });
  } catch (error) {
    console.error('Get family requests error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
};

exports.getFamilyRequestById = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      `SELECT fr.*, u.full_name as user_name, u.email as user_email
       FROM family_requests fr
       LEFT JOIN users u ON fr.user_id = u.id
       WHERE fr.id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Family request not found',
      });
    }

    res.json({
      success: true,
      data: result.rows[0],
    });
  } catch (error) {
    console.error('Get family request error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
};

exports.approveFamilyRequest = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      `UPDATE family_requests
       SET status = 'approved',
           admin_approved_by = $1,
           approved_at = CURRENT_TIMESTAMP,
           updated_at = CURRENT_TIMESTAMP
       WHERE id = $2
       RETURNING *`,
      [req.admin.id, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Family request not found',
      });
    }

    res.json({
      success: true,
      message: 'Family request approved successfully',
      data: result.rows[0],
    });
  } catch (error) {
    console.error('Approve family request error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
};

exports.rejectFamilyRequest = async (req, res) => {
  try {
    const { id } = req.params;
    const { reason } = req.body;

    const result = await pool.query(
      `UPDATE family_requests
       SET status = 'rejected',
           updated_at = CURRENT_TIMESTAMP
       WHERE id = $1
       RETURNING *`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Family request not found',
      });
    }

    res.json({
      success: true,
      message: 'Family request rejected successfully',
      data: result.rows[0],
    });
  } catch (error) {
    console.error('Reject family request error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
};
