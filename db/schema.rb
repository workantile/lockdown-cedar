# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170620150218) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "access_logs", force: :cascade do |t|
    t.date     "access_date"
    t.boolean  "access_granted"
    t.string   "msg"
    t.integer  "member_id"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "member_name"
    t.string   "member_type"
    t.string   "door_controller_location"
    t.string   "billing_plan"
    t.integer  "door_controller_id"
    t.datetime "access_date_time"
  end

  create_table "admins", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree

  create_table "all_member_events", force: :cascade do |t|
    t.datetime "scheduled"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "name"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0
    t.integer  "attempts",   default: 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "door_controllers", force: :cascade do |t|
    t.string   "address"
    t.string   "location"
    t.string   "success_response"
    t.string   "error_response"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "doors", force: :cascade do |t|
    t.string   "name"
    t.string   "address"
    t.string   "shared_secret"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "members", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "rfid"
    t.string   "member_type"
    t.date     "anniversary_date"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "billing_plan"
    t.boolean  "key_enabled",            default: true
    t.string   "task"
    t.string   "pay_simple_customer_id"
    t.date     "termination_date"
    t.date     "usage_email_sent"
    t.date     "last_date_invoiced"
  end

  create_table "pending_updates", force: :cascade do |t|
    t.string   "description"
    t.integer  "delayed_job_id"
    t.integer  "member_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "snapshots", force: :cascade do |t|
    t.string   "category"
    t.string   "item"
    t.integer  "count"
    t.date     "snapshot_date"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

end
