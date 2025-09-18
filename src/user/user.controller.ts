import {
  Controller,
  Get,
  Query,
  Param,
  Put,
  Body,
  Post,
  Delete,
  Patch,
  HttpException,
  HttpStatus,
  Redirect,
} from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { UserService } from './user.service';
import { UserDto } from './dto/user.dto';
import { Public } from 'src/auth/decorators/public.decorator';

@Controller('user')
@ApiTags('用户管理 User')
export class UserController {
  constructor(private readonly userService: UserService) {}

  // 分页查询
  @Get('/page')
  async findAll(
    @Query('keyword') keyword: string,
    @Query('pageNum') pageNum: number,
    @Query('pageSize') pageSize: number,
  ) {
    console.log(keyword, pageNum, pageSize);
    const list = await this.userService.findPage({ keyword, pageNum, pageSize });
    const count = await this.userService.countAll({ keyword });
    return {
      records: list,
      total: count,
    };
  }

  @Get('/list')
  async list(@Query('keyword') keyword: string) {
    const list = await this.userService.findList({ keyword });
    return list;
  }

  // 创建注册
  @Public()
  @Post('/register')
  async register(@Body() dataDto: UserDto) {
    return await this.userService.create(dataDto);
  }

  // 登录账号
  @Public()
  @Post('/login')
  @Redirect('/api/auth/login', 307) // http状态码 POST请求 - 308永久 307临时
  async login() {
    return;
  }

  // 获取信息
  @Get('/info')
  @Redirect('/api/auth/profile', 302) // http状态码 GET请求 - 301永久 302临时
  async info() {
    return;
  }

  // 修改
  // @Patch('/update/:id')
  @Put('/update/:id')
  async update(@Param('id') id: string, @Body() dataDto: UserDto) {
    // 数据库返回
    // { "acknowledged": true, "modifiedCount": 1, "upsertedId": null, "upsertedCount": 0, "matchedCount": 1 }
    const data = await this.userService.updateOne(id, dataDto);
    // 修改成功 返回当前数据的id
    if (data.modifiedCount === 1) {
      // return id;
      return this.userService.findById(id);
    } else {
      throw new HttpException('更新失败', HttpStatus.BAD_REQUEST);
    }
  }

  // get 中的 id 要和 @Param('id')  一致
  // 查询 根据 id 查询
  @Get('/getById/:id')
  findOne(@Param('id') id: string) {
    return this.userService.findById(id);
  }

  @Delete('/deleteById/:id')
  deleteById(@Param('id') id: string) {
    return this.userService.deleteOne(id);
  }
}
