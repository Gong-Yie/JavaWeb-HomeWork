package com.classsys.model;

public class Student {
    private int id;
    private String name;
    private String studentNo;
    private String phone;
    private int dutyDay;
    private String avatar;
    private int classId;
    private String className;
    private String username;
    private String gender;

    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getStudentNo() { return studentNo; }
    public void setStudentNo(String studentNo) { this.studentNo = studentNo; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public int getDutyDay() { return dutyDay; }
    public void setDutyDay(int dutyDay) { this.dutyDay = dutyDay; }
    public String getAvatar() { return avatar; }
    public void setAvatar(String avatar) { this.avatar = avatar; }
    public int getClassId() { return classId; }
    public void setClassId(int classId) { this.classId = classId; }
    public String getClassName() { return className; }
    public void setClassName(String className) { this.className = className; }
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
}