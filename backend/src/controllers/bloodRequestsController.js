const pool = require('../config/database');

exports.getAllBloodRequests = async (req, res) => {
  try {
    const { status } = req.query;

    let query = `
      SELECT br.*, u.full_name as user_name, u.email as user_email
      FROM blood_requests br
      LEFT JOIN users u ON br.user_id = u.id
      ORDER BY br.created_at DESC
    `;
    let params = [];

    if (status) {
      query = `
        SELECT br.*, u.full_name as user_name, u.email as user_email
        FROM blood_requests br
        LEFT JOIN users u ON br.user_id = u.id
        WHERE br.status = $1
        ORDER BY br.created_at DESC
      `;
      params = [status];
    }

    const result = await pool.query(query, params);

    res.json({
      success: true,
      data: result.rows,
    });
  } catch (error) {
    console.error('Get blood requests error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
};

exports.getBloodRequestById = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      `SELECT br.*, u.full_name as user_name, u.email as user_email
       FROM blood_requests br
       LEFT JOIN users u ON br.user_id = u.id
       WHERE br.id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Blood request not found',
      });
    }

    res.json({
      success: true,
      data: result.rows[0],
    });
  } catch (error) {
    console.error('Get blood request error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
};

exports.approveBloodRequest = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      `UPDATE blood_requests
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
        message: 'Blood request not found',
      });
    }

    res.json({
      success: true,
      message: 'Blood request approved successfully',
      data: result.rows[0],
    });
  } catch (error) {
    console.error('Approve blood request error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
};

exports.rejectBloodRequest = async (req, res) => {
  try {
    const { id } = req.params;
    const { reason } = req.body;

    const result = await pool.query(
      `UPDATE blood_requests
       SET status = 'cancelled',
           cancelled_reason = $1,
           cancelled_at = CURRENT_TIMESTAMP,
           updated_at = CURRENT_TIMESTAMP
       WHERE id = $2
       RETURNING *`,
      [reason, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Blood request not found',
      });
    }

    res.json({
      success: true,
      message: 'Blood request rejected successfully',
      data: result.rows[0],
    });
  } catch (error) {
    console.error('Reject blood request error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
};
