package org.example.heritage.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.example.heritage.pojo.dto.ProjectPageQueryDTO;
import org.example.heritage.pojo.entity.HeritageProject;
import org.example.heritage.pojo.vo.ProjectDetailVO;
import org.example.heritage.pojo.vo.ProjectListVO;
import org.example.heritage.pojo.vo.ProjectStatsVO;
import org.example.heritage.pojo.vo.SearchVO;

import java.util.List;

@Mapper
public interface HeritageProjectMapper extends BaseMapper<HeritageProject> {

    List<ProjectListVO> selectProjectList(@Param("query") ProjectPageQueryDTO query);

    Long countProjectList(@Param("query") ProjectPageQueryDTO query);

    ProjectDetailVO selectProjectDetail(@Param("projectId") Integer projectId);

    ProjectStatsVO selectProjectStats(@Param("projectId") Integer projectId);

    List<SearchVO> searchProjects(@Param("keyword") String keyword);
}
