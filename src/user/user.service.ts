import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { User } from './schemas/user.schema';
import { UserDto } from './dto/user.dto';

@Injectable()
export class UserService {
  constructor(
    // 依赖注入
    @InjectModel(User.name) private readonly userModel: Model<User>,
  ) {}

  async findPage({ keyword = '', pageNum = 1, pageSize = 10 }): Promise<any> {
    const whereOpt: any = {};

    if (keyword) {
      const reg = new RegExp(keyword, 'i');
      whereOpt.nickname = { $regex: reg }; // 模糊搜索 'abc'
    }

    return await this.userModel
      .find(whereOpt)
      .sort({ _id: 1 }) // _id倒序
      .skip((pageNum - 1) * pageSize) // 跳过
      .limit(pageSize) // 限制
      .exec();
  }

  async countAll({ keyword = '' }) {
    const whereOpt: any = {};

    if (keyword) {
      const reg = new RegExp(keyword, 'i');
      whereOpt.username = { $regex: reg }; // 模糊搜索 'abc'
    }

    return await this.userModel.countDocuments(whereOpt);
  }

  async findList({ keyword = '' }): Promise<any> {
    const whereOpt: any = {};

    if (keyword) {
      const reg = new RegExp(keyword, 'i');
      whereOpt.username = { $regex: reg }; // 模糊搜索 'abc'
    }

    return await this.userModel
      .find(whereOpt)
      .sort({ _id: 1 }) // _id倒序
      .exec();
  }

  // 创建用户
  async create(dataDto: UserDto): Promise<any> {
    const createUser = new this.userModel(dataDto);
    return await createUser.save();
  }

  // 查询单个用户信息
  async findById(id: string): Promise<any> {
    return await this.userModel.findOne({ id });
  }

  // 查询单个用户(登录)
  async findByUsernameAndPassword(username: string, password: string): Promise<any> {
    return await this.userModel.findOne({ username, password });
  }

  // 更新单个用户
  async updateOne(id: string, updateData: UserDto): Promise<any> {
    return await this.userModel.updateOne({ id: id }, updateData);
  }

  // 删除单个用户
  async deleteOne(id: string): Promise<any> {
    return await this.userModel.findOneAndDelete({ id });
  }
}
